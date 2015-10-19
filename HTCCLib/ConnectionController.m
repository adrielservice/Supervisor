//
//  ConnectionController.m
//  HTCC Sample
//
//  Created by Arkady on 10/22/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "ConnectionController.h"
#import "DDCometClient.h"
#import "DDCometMessage.h"
#import "DDCometSubscription.h"
#import "xCSRF.h"

@interface ConnectionController () <DDCometClientDelegate>
@end

@implementation ConnectionController {
    // instance variables declared in implementation context
    NSString *baseURL;
    NSDictionary *channels;
    int subscribedChannels;
    DDCometClient *comet;
    xCSRF *csrf;
}

+ (instancetype) createWithURL:(NSString *)baseURL {
    if (baseURL.length) {
        ConnectionController *cContr = [[self alloc] init];
        cContr->baseURL = baseURL;
        cContr->channels = @{kCometDevicesChannel: @"devicesChanged:",
                             kCometChannelsChannel: @"channelsChanged:",
                             kCometCallsChannel: @"callsChanged:",
                             kCometChatChannel: @"chatsChanged:",
                             kCometEmailChannel: @"emailsChanged:"};
        cContr->comet = [[DDCometClient alloc] initWithURL:[NSURL URLWithString:kCometURL relativeToURL:[NSURL URLWithString:baseURL]]];
        cContr->comet.delegate = cContr;
        cContr->_me = [Me initMe];
        cContr->csrf = [[xCSRF alloc] init];
        return cContr;
    }
    else
        return nil;
}

- (void)startCometd {
    //Init CometD
    [comet scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handshake {
    [comet handshake];
}

- (void)disconnectSynchronous {
    [comet disconnectSynchronous];
}

- (void)disconnect {
    [comet disconnect];
}


- (void)submit2HTCC:(NSString *)url
             method:(NSString *)method
             params:(NSDictionary *)params
               user:(NSString *)user
           password:(NSString *)password
  completionHandler:(void (^)(NSDictionary *response))completionHandler {
    
    if (url.length == 0 && method.length == 0) {
        //both URL and method are empty => return
        [self logRequest:@"Request or Method are missing" direction:toHTCC];
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSMutableURLRequest *request;
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:baseURL]]
                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                  timeoutInterval:30.0];

    [request setHTTPMethod:method];

    // Authorization header
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", user, password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

// SSO authorization
//    [request setValue:user forHTTPHeaderField:@"SUSERNAME"];
//    [request setValue:[[NSProcessInfo processInfo] globallyUniqueString] forHTTPHeaderField:@"SSID"];
    
    // CSRF
    if (csrf.headerName && csrf.headerValue) {
        [request setValue:csrf.headerValue forHTTPHeaderField:csrf.headerName];
    }
    
    static int counter = 0;

    if ([method isEqualToString:@"GET"]) {
        [self logRequest:[NSString stringWithFormat:@"%d: Method: GET, URL: %@", counter, [baseURL stringByAppendingPathComponent:url]] direction:toHTCC];
    }
    
    else if ([method isEqualToString:@"POST"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSError *error;
        if (params.count) {
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error]];
        }
        [self logRequest:[NSString stringWithFormat:@"%d: Method: POST, URL: %@\nBody: %@\n", counter, [baseURL stringByAppendingPathComponent:url], params] direction:toHTCC];
    }
    
    else {
        [self logRequest:@"Unknown HTTP Method" direction:toHTCC];
        return;
    }
    
    int counter_copy = counter++;    
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary *responseDict = nil;
        if ([data length] > 0 && error == nil) {
            
            // Check if X-CSRF-HEADER is present and store token
            //     "X-CSRF-HEADER" = "X-CSRF-TOKEN";
            //     "X-CSRF-TOKEN" = "4fd4bfc0-baf1-450d-a62f-8cfe0f3f3dd0";
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            if (headers[@"X-CSRF-HEADER"] && headers[headers[@"X-CSRF-HEADER"]]) {
                csrf.headerName = headers[@"X-CSRF-HEADER"];
                csrf.headerValue = headers[csrf.headerName];
                comet.csrf = csrf;
            }
            
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self logRequest:[NSString stringWithFormat:@"%d: %@", counter_copy, responseStr] direction:fromHTCC];
            // Parse the responseData, which we asked to be in JSON format for this request, into an NSDictionary using NSJSONSerialization.
            NSError *jsonParsingError = nil;
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (jsonParsingError) {
                [self logRequest:[NSString stringWithFormat:@"JSON parsing error: %@, counter: %d", jsonParsingError, counter++] direction:fromHTCC];
            }
            else {
                // Check for errors from HTCC
                NSNumber *retCode = responseDict[@"statusCode"];
                if (retCode && (retCode.integerValue == hOk || retCode.integerValue == hPartialOk)) {
                    // Ok
                    if (completionHandler) {
                        completionHandler(responseDict);
                    }
                }
                else {
                    // Error
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Error from HTCC Server"
                                          message: [NSString stringWithFormat:@"statusCode: %@, statusMessage: %@", retCode, responseDict[@"statusMessage"]]
                                          delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alert show];
                    });
                    
                }
            }
        }
        else if (error != nil){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Error accessing HTCC Server"
                                  message: [NSString stringWithFormat:@"URL: %@, Error: %@", [baseURL stringByAppendingPathComponent:url], error]
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }
    }];
    [dataTask resume];
}

- (void)logRequest:(NSString *)txt2Log direction:(int)dir {
    
    if (txt2Log.length) {
        NSString *direction = (dir == toHTCC) ? @"toHTCC: " : @"fromHTCC: ";
        NSLog(@"%@%@", direction, txt2Log);
        
        //Update Log View
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLogNotification
                                                            object:self
                                                          userInfo:@{@"direction":@(dir), @"text":txt2Log}];
    }
}

- (void)unsubscribeFromAllChannels {
    //Unsubscribe from all CometD channels
    [channels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [comet unsubsubscribeFromChannel:key target:self selector:NSSelectorFromString(obj)];
    }];
    subscribedChannels = 0;
}

#pragma mark - DDComet Client Delegate methods

- (void)cometClientHandshakeDidSucceed:(DDCometClient *)client
{
	[self logRequest:@"CometD Handshake succeeded!" direction:fromHTCC];
    
    //Subscribe to CometD channels
    subscribedChannels = (int)[[channels allKeys] count];
    [channels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [client subscribeToChannel:key target:self selector:NSSelectorFromString(obj)];
    }];
}

- (void)cometClient:(DDCometClient *)client handshakeDidFailWithError:(NSError *)error
{
	[self logRequest:@"CometD Handshake failed!" direction:fromHTCC];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"CometD Handshake failed!"
                          message: [NSString stringWithFormat:@"Error: %@", error]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)cometClientConnectDidSucceed:(DDCometClient *)client
{
	[self logRequest:@"CometD Connect succeeded!" direction:fromHTCC];
}

- (void)cometClient:(DDCometClient *)client connectDidFailWithMessage:(DDCometMessage *)message
{
	[self logRequest:[NSString stringWithFormat:@"CometD Connect failed, error: %@", message.error] direction:fromHTCC];
    if ([message.advice[@"reconnect"] isKindOfClass:[NSString class]] && [message.advice[@"reconnect"] isEqualToString:@"handshake"]) {
        [self logRequest:@"CometD reconnect handshake advice received" direction:fromHTCC];
       
        // @DB - not a public API
        // [comet stop];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //We don't need to StartContactCenter as a result of posting notification
            _subscribtionDoneAction = nil;
            [comet handshake];
        });
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"CometD Connect failed!"
                              message: [NSString stringWithFormat:@"Error: %@", message.error]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

- (void)cometClient:(DDCometClient *)client subscriptionDidSucceed:(DDCometSubscription *)subscription
{
	[self logRequest:[NSString stringWithFormat:@"CometD Subsrciption succeeded, channel: %@", subscription.channel] direction:fromHTCC];
    
    subscribedChannels--;
    
    if (subscribedChannels == 0 && _subscribtionDoneAction) {
        _subscribtionDoneAction();
    }
}

- (void)cometClient:(DDCometClient *)client subscription:(DDCometSubscription *)subscription didFailWithError:(NSError *)error
{
	[self logRequest:[NSString stringWithFormat:@"CometD Subsrciption failed, channel: %@, error: %@", subscription.channel, error] direction:fromHTCC];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"CometD Subsrciption failed,!"
                          message: [NSString stringWithFormat:@"Channel: %@, Error: %@", subscription.channel, error]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)devicesChanged:(DDCometMessage *)message
{
    if ([message.data isKindOfClass:[NSDictionary class]]) {
        if ([message.data[@"messageType"] isKindOfClass:[NSString class]] && [message.data[@"messageType"] isEqualToString:@"DeviceStateChangeMessage"]) {
            [self logRequest:[NSString stringWithFormat:@"CometD Devices Changed, %p", message] direction:fromHTCC];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_me updateDevices:message.data[@"devices"]];
            });
        }
        else if (message.data[@"errorMessage"]){
            // Error
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Error from HTCC Server"
                                  message: message.data[@"errorMessage"]
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }
    }
}

- (void)channelsChanged:(DDCometMessage *)message
{
    if ([message.data isKindOfClass:[NSDictionary class]] &&
        [message.data[@"messageType"] isKindOfClass:[NSString class]] &&
        [message.data[@"messageType"] isEqualToString:@"ChannelStateChangeMessageV2"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logRequest:[NSString stringWithFormat:@"CometD Channels Changed, %p", message] direction:fromHTCC];
            [_me updateChannels:message.data[@"channels"]];
        });
    }
}

- (void)callsChanged:(DDCometMessage *)message
{
    if ([message.data isKindOfClass:[NSDictionary class]]) {
        if ([message.data isKindOfClass:[NSDictionary class]] && [message.data[@"notificationType"] isKindOfClass:[NSString class]]) {
            if ([message.data[@"notificationType"] isEqualToString:@"StatusChange"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self logRequest:[NSString stringWithFormat:@"CometD Calls Changed, %p", message] direction:fromHTCC];
                    [_me updateInteraction:_me.calls newInteraction:message.data[@"call"] notification:kUpdateCallNotification];
                });
            }
            else if ([message.data[@"notificationType"] isEqualToString:@"AttachedDataChanged"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self logRequest:[NSString stringWithFormat:@"CometD Attached Data Changed, %p", message] direction:fromHTCC];
                    [_me updateInteraction:_me.calls newInteraction:message.data[@"call"] notification:kUpdateCallUserDataNotification];
                });
            }
            else if ([message.data[@"notificationType"] isEqualToString:@"ParticipantsUpdated"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self logRequest:[NSString stringWithFormat:@"CometD Participants Updated, %p", message] direction:fromHTCC];
                    [_me updateInteraction:_me.calls newInteraction:message.data[@"call"] notification:kUpdateCallParticipantsNotification];
                });
            }
        }
    }
}

- (void)chatsChanged:(DDCometMessage *)message
{
    static int count = 0;

    if ([message.data isKindOfClass:[NSDictionary class]] && [message.data[@"notificationType"] isKindOfClass:[NSString class]]) {
        if ([message.data[@"notificationType"] isEqualToString:@"StatusChange"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Chat Status Changed, %p - %d", message, count] direction:fromHTCC];
                [_me updateInteraction:_me.chats newInteraction:message.data[@"chat"] notification:kUpdateChatStatusNotification];
                count++;
            });
        }
        else if ([message.data[@"notificationType"] isEqualToString:@"ParticipantsUpdated"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Chat Participants Changed, %p - %d", message, count] direction:fromHTCC];
                [_me updateInteraction:_me.chats newInteraction:message.data[@"chat"] notification:kUpdateChatParticipantsNotification];
                count++;
            });
        }
        else if ([message.data[@"notificationType"] isEqualToString:@"PropertiesUpdated"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Chat UserData Changed, %p - %d", message, count] direction:fromHTCC];
                [_me updateInteraction:_me.chats newInteraction:message.data[@"chat"] notification:kUpdateChatUserDataNotification];
                count++;
            });
        }
        else if ([message.data[@"notificationType"] isEqualToString:@"NewMessages"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Chat Messages Changed, %p - %d", message, count] direction:fromHTCC];
                NSMutableDictionary *fix = [NSMutableDictionary dictionaryWithDictionary:message.data];
                //Fix - there is no "id" in the message
                if (!fix[@"id"] && [fix[@"chatUri"] isKindOfClass:[NSString class]]) {
                    fix[@"id"] = [[fix[@"chatUri"] pathComponents] lastObject];
                    [_me updateInteraction:_me.chats newInteraction:fix notification:kUpdateChatMessagesNotification];
                }
                count++;
            });
        }
    }
}

- (void)emailsChanged:(DDCometMessage *)message
{
    static int count = 0;
    
    if ([message.data isKindOfClass:[NSDictionary class]] && [message.data[@"notificationType"] isKindOfClass:[NSString class]]) {
        if ([message.data[@"notificationType"] isEqualToString:@"StatusChange"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Email Status Changed, %p - %d", message, count] direction:fromHTCC];
                [_me updateInteraction:_me.emails newInteraction:message.data[@"email"] notification:kUpdateEmailStatusNotification];
                count++;
            });
        }
        else if ([message.data[@"notificationType"] isEqualToString:@"PropertiesUpdated"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logRequest:[NSString stringWithFormat:@"CometD Email UserData Changed, %p - %d", message, count] direction:fromHTCC];
                [_me updateInteraction:_me.emails newInteraction:message.data[@"email"] notification:kUpdateEmailUserDataNotification];
                count++;
            });
        }
    }
}

@end

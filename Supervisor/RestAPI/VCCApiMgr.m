//
//  VCCApiMgr.m
//  Supervisor
//
//  Created by David Beilis on 10/3/15.
//  Copyright © 2015 Genesys. All rights reserved.
//

#import "VCCApiMgr.h"
#import <RestKit/RestKit.h>

@implementation VCCApiMgr

@synthesize userSession;

#pragma mark Singleton Methods

- (id) init {
    [self configureRestKit];
    
    return self;
};

+ (id) sharedManager {
    static VCCApiMgr *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[VCCApiMgr alloc] init];
    });
    return _sharedInstance;
};

+ (void)basicAuthForRequest:(NSMutableURLRequest *)request withUsername:(NSString *)username andPassword:(NSString *)password {
    // Cast username and password as CFStringRefs via Toll-Free Bridging
    CFStringRef usernameRef = (__bridge CFStringRef)username;
    CFStringRef passwordRef = (__bridge CFStringRef)password;
    
    // Reference properties of the NSMutableURLRequest
    CFHTTPMessageRef authoriztionMessageRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (__bridge CFStringRef)[request HTTPMethod], (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    
    // Encodes usernameRef and passwordRef in Base64
    CFHTTPMessageAddAuthentication(authoriztionMessageRef, nil, usernameRef, passwordRef, kCFHTTPAuthenticationSchemeBasic, FALSE);
    
    // Creates the 'Basic - <encoded_username_and_password>' string for the HTTP header
    CFStringRef authorizationStringRef = CFHTTPMessageCopyHeaderFieldValue(authoriztionMessageRef, CFSTR("Authorization"));
    
    // Add authorizationStringRef as value for 'Authorization' HTTP header
    [request setValue:(__bridge NSString *)authorizationStringRef forHTTPHeaderField:@"Authorization"];
    
    // Cleanup
    CFRelease(authorizationStringRef);
    CFRelease(authoriztionMessageRef);
    
}

#pragma mark REST methods

- (void) registerWithUser:(User*)user callback:(id<UpdateView>)callback{
    
    // clean resources
    if (userSession) {
        if (userSession.user) {
            userSession.user = nil;
        }
        
        user = nil;
    }
    
    userSession = nil;
    
    user.username = [user.firstName stringByAppendingString:user.lastName];
    
    [[RKObjectManager sharedManager] postObject:user path:@"/users" parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSLog(@"It Worked: %@", [mappingResult array][0]);
                                            
                                            self.userSession = [mappingResult array][0];
                                            // self.userSession.user = user;
                                            self.userSession.phoneNumber = @"18489993383";
                                            
                                            NSLog(@"UserId: %@", self.userSession.userId);
                                            
                                            [callback update];
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                        }];
};

- (void) configureRestKit {
    
    /*
     api/v2/me?subresources=features,devices
     
     /api/v1/stats?type=queue
     /api/v1/stats?type=skill
     /api/v1/v2/users?fields=*&limit=20&offset=0&order=Ascending&roles=ROLE_AGENT&sortBy=lastName,firstName&statistics.channels.voice.state=NotReady,Ready&subresources=devices,statistics,calls
     
     https://premier.angel.com/internal-api/statistics/dashboard/multiple-historical-query?from=1443854700000&id=35989d93-4706-47ac-8eff-a5a27239b030,5744ff06-53fc-46f2-a797-6283da2ddf40&numValues=2147483647&statistic=Total_Answered,Total_Abandoned&to=1443858600000
     
     */
    
    //---------------------------------------------------------------------------------------------------

    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://premier.angel.com/"];
    // NSURL *baseURL = [NSURL URLWithString:@"http://172.20.27.208:64939/"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [objectManager setRequestSerializationMIMEType: RKMIMETypeJSON];
    
    // what to print
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("Restkit/Network", RKLogLevelDebug);
    
    //---------------------------------------------------------------------------------------------------
    
    
    RKObjectMapping *userSessionRequestMapping =  [[User defineRequestMapping] inverseMapping];
    
    [objectManager addRequestDescriptor: [RKRequestDescriptor requestDescriptorWithMapping:userSessionRequestMapping objectClass:[User class] rootKeyPath:nil method:RKRequestMethodPOST]];
    
    // setup object mappings
    RKObjectMapping *userSessionResponseMapping = [RKObjectMapping mappingForClass:[UserSession class]];
    [userSessionResponseMapping addAttributeMappingsFromDictionary:@{
                                                                     @"userId": @"userId",
                                                                     @"phoneNumber": @"phoneNumber"
                                                                     }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseSessionDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:userSessionResponseMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"users"
                                                keyPath:@""
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseSessionDescriptor];

}

- (void) getStats {
    
}


@end

//
//  LoginViewController.m
//  HTCC Sample
//
//  Created by Arkady on 10/21/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "NSArray+HTCC.h"
#import "UIAlertViewBlock.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)login:(UIButton *)sender;

@end

@implementation LoginViewController
{
#ifdef SIPEP
    //SIP EP
    id<GSEndpoint> sipEP;
#endif
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add this as an observer for CometD Subscription Succeed notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cometSubscribed) name:kCometdSubscriptionSucceed object:nil];
    
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _userTextField.text = appDelegate.htccUser;
    _passwordTextField.text = appDelegate.htccPassword;
    
    [appDelegate.htccConnection startCometd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(UIButton *)sender {
    // Save login credentials
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.htccUser = _userTextField.text;
    appDelegate.htccPassword = _passwordTextField.text;
        
    // Init Target selection history
    if (appDelegate.htccConnection.me.history == nil) {
        appDelegate.htccConnection.me.history = [NSMutableArray arrayWithCapacity:1];
    }
    
    if ([appDelegate.htccUser length] > 0) {
        
        // We need to perform "GET" on /me with auth first, in order to retrieve a cookie that will be used by CometD for authorization
        [appDelegate.htccConnection submit2HTCC:[kMeURL stringByAppendingString:@"?subresources=*"]
                                         method:@"GET"
                                         params:nil
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:^(NSDictionary *response) {
                                  appDelegate.htccConnection.me.loggedIn = TRUE;
                                  if ([response[@"user"] isKindOfClass:[NSDictionary class]]) {
                                          [appDelegate.htccConnection.me updateDevices:response[@"user"][@"devices"]];
                                          [appDelegate.htccConnection.me updateChannels:response[@"user"][@"channels"]];
                                      if ([response[@"user"][@"id"] isKindOfClass:[NSString class]]) {
                                          appDelegate.htccConnection.me.myID = response[@"user"][@"id"];
                                      }
                                      if ([response[@"user"][@"settings"] isKindOfClass:[NSDictionary class]] &&
                                          [response[@"user"][@"settings"][@"interaction-workspace"] isKindOfClass:[NSDictionary class]]) {
                                          appDelegate.htccConnection.me.wsSettings = response[@"user"][@"settings"][@"interaction-workspace"];
                                      }
                                  }
                                  
                                  //Handshake CometD. Then Subsribe to channels. Then perform StartContactCenterSession in Comet Subscribed delegate.
                                  appDelegate.htccConnection.subscribtionDoneAction = ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kCometdSubscriptionSucceed object:self];
                                  };
                                  [appDelegate.htccConnection handshake];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self performSegueWithIdentifier: @"loginSegue" sender:self];

                                  });
                                  
                                  //Retrieve Agent States
                                  [appDelegate.htccConnection submit2HTCC:kAgentStatesURL
                                                                   method:@"GET"
                                                                   params:nil
                                                                     user:appDelegate.htccUser
                                                                 password:appDelegate.htccPassword
                                                        completionHandler:^(NSDictionary *response) {
                                                            if ([response[@"settings"] isKindOfClass:[NSArray class]] &&
                                                                [response[@"settings"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                appDelegate.htccConnection.me.agentStates = response[@"settings"];
                                                            }
                                                        }];
                                  
                                  //Retrieve Business Attributes
                                  [appDelegate.htccConnection submit2HTCC:kBusinessAttribURL
                                                                   method:@"GET"
                                                                   params:nil
                                                                     user:appDelegate.htccUser
                                                                 password:appDelegate.htccPassword
                                                        completionHandler:^(NSDictionary *response) {
                                                            NSString *toastAttName = appDelegate.htccConnection.me.wsSettings[@"toast.case-data.format-business-attribute"];
                                                            NSString *caseAttName = appDelegate.htccConnection.me.wsSettings[@"interaction.case-data.format-business-attribute"];
                                                            NSString *dispCodeAttName = appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.value-business-attribute"];
                                                            NSString *emailFromAttName = appDelegate.htccConnection.me.wsSettings[@"email.from-addresses"];

                                                            NSArray *ba = response[@"businessAttributes"];
                                                            if ([ba isKindOfClass:[NSArray class]] && [ba areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                [ba enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                    if ([obj[@"name"] isKindOfClass:[NSString class]]) {
                                                                        if ([obj[@"name"] isEqualToString:toastAttName] &&
                                                                            [obj[@"values"] isKindOfClass:[NSArray class]] &&
                                                                            [obj[@"values"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                            //Toast Attribute
                                                                            appDelegate.htccConnection.me.toastData = obj[@"values"];
                                                                        }
                                                                        if ([obj[@"name"] isEqualToString:caseAttName] &&
                                                                            [obj[@"values"] isKindOfClass:[NSArray class]] &&
                                                                            [obj[@"values"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                            //Case Attribute
                                                                            appDelegate.htccConnection.me.caseData = obj[@"values"];
                                                                        }
                                                                        if ([obj[@"name"] isEqualToString:dispCodeAttName] &&
                                                                            [obj[@"values"] isKindOfClass:[NSArray class]] &&
                                                                            [obj[@"values"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                            //Disposition Code Attribute
                                                                            appDelegate.htccConnection.me.dispCodes = obj[@"values"];
                                                                        }
                                                                        if ([obj[@"name"] isEqualToString:emailFromAttName] &&
                                                                            [obj[@"values"] isKindOfClass:[NSArray class]] &&
                                                                            [obj[@"values"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                            //Email From Addresses Attribute
                                                                            appDelegate.htccConnection.me.emailFromAddresses = obj[@"values"];
                                                                        }
                                                                    }
                                                                }];
                                                            }
                                                        }];
                                  
                                  //Retrieve Contacts
                                  [appDelegate.htccConnection submit2HTCC:kContactsURL
                                                                   method:@"GET"
                                                                   params:nil
                                                                     user:appDelegate.htccUser
                                                                 password:appDelegate.htccPassword
                                                        completionHandler:^(NSDictionary *response) {
                                                            if ([response[@"contacts"] isKindOfClass:[NSArray class]] &&
                                                                [response[@"contacts"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                                                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[response[@"contacts"] count]];
                                                                for (NSDictionary *sk in response[@"contacts"]) {
                                                                    if ([sk[@"id"] isKindOfClass:[NSString class]] &&
                                                                        ![sk[@"id"] isEqualToString:appDelegate.htccConnection.me.myID]) {
                                                                        //Do not add ourself
                                                                        [arr addObject:[Contact createContact:sk]];
                                                                    }
                                                                }
                                                                appDelegate.htccConnection.me.contacts = arr;
                                                            }
                                                        }];
#ifdef SIPEP
                                  if (appDelegate.sipEnabled)
                                      [self initSIPEP];
#endif
                             }];
    }
}

- (IBAction)logout:(UIStoryboardSegue *)segue {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    for (Interaction *interaction in appDelegate.htccConnection.me.chats) {
        if ([interaction.state isEqualToString:@"Accepted"] && interaction.ixnID) {
            //Mark chat "Complete" to prevent unwanted CometD notifications
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:interaction.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Complete"}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        }
    }

    appDelegate.htccConnection.me.loggedIn = FALSE;
    [appDelegate.htccConnection.me.calls removeAllObjects];
    [appDelegate.htccConnection.me.chats removeAllObjects];
    [appDelegate.htccConnection.me.emails removeAllObjects];
    [appDelegate.htccConnection.me.devices removeAllObjects];
    [appDelegate.htccConnection.me.channels removeAllObjects];

    //Reset history
    appDelegate.htccConnection.me.history = nil;
    
    [self endContactCenterSession];
    
#ifdef SIPEP
    if (appDelegate.sipEnabled)
        [self closeSIPEP];
#endif
}

- (void)endContactCenterSession {

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    //Unsubscribe from all CometD channels and disconnect
    [appDelegate.htccConnection unsubscribeFromAllChannels];
    [appDelegate.htccConnection disconnect];
    
    // End ContactCenterSession
    [appDelegate.htccConnection submit2HTCC:kMeURL
                                     method:@"POST"
                                     params:@{@"operationName": @"EndContactCenterSession"}
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:nil];
}

#pragma mark - Comet Subscribed delegate

- (void)cometSubscribed
{
    // Start ContactCenterSession
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithCapacity:1];
    [body setDictionary:@{@"operationName": @"StartContactCenterSession",
                          @"channels":(appDelegate.eServicesEnabled) ? @[@"voice", @"chat", @"email"] : @[@"voice"]}];
    if (appDelegate.notifyToken && appDelegate.apnEnabled) {
#ifdef DEBUG
        [body addEntriesFromDictionary:@{@"mobileSession":
                                             @{@"mobileDeviceId": appDelegate.notifyToken,
                                               @"mobilePushType": @"IOS",
                                               @"debug": @TRUE}}];
#else
        [body addEntriesFromDictionary:@{@"mobileSession":
                                             @{@"mobileDeviceId": appDelegate.notifyToken,
                                               @"mobilePushType": @"IOS"}}];
#endif
    }
    [appDelegate.htccConnection submit2HTCC:kMeURL
                                     method:@"POST"
                                     params:body
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:^(NSDictionary *response) {
                              // Post notification to make Call, Chat and Email ViewControllers Update Info - needed in case app was started during active interaction
                              // App may became active but without Login performed, so updateXXXXInfo didn't update status when was called during app launch.
                              // We pass flag in UserInfo to process (and not to ignore) active interactions, that do not start with "Invite"
                              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification
                                                                                  object:self
                                                                                userInfo:@{@"afterLogin": @YES}];
                          }
     ];
}

#pragma mark - TextField delegates

//Dismiss keyboard when Return key is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    if (textField == _userTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if (textField == _passwordTextField) {
        [self login:nil];
    }
    return YES;
}


#pragma mark - SIP EP

#ifdef SIPEP

- (NSString *)getIPAddresses {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    NSString *vpnAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                }
                else if([name isEqualToString:@"pdp_ip0"]) {
                    // Interface is the cell connection on the iPhone
                    cellAddress = addr;
                }
                else if ([name isEqualToString:@"utun0"]) {//if ([name isEqualToString:@"ppp0"]) {
                    // Interface is the VPN connection on the iPhone
                    vpnAddress = addr;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    /*
     NAME: "lo0" addr: 0.0.0.0
     NAME: "lo0" addr: 127.0.0.1             Local host IP address
     NAME: "lo0" addr: 0.0.0.0
     NAME: "pdp_ip0" addr: 10.170.234.21     Cellular IP address
     NAME: "pdp_ip0" addr: 0.0.0.0
     NAME: "pdp_ip0" addr: 0.0.0.0
     NAME: "pdp_ip0" addr: 0.0.0.0
     NAME: "en0" addr: 0.0.0.0
     NAME: "en0" addr: 192.168.254.87        WIFI IP address
     NAME: "awdl0" addr: 0.0.0.0
     NAME: "ppp0" addr: 135.225.30.8         VPN IP address
     */
    
    if (vpnAddress)
        return vpnAddress;
    else if (wifiAddress)
        return wifiAddress;
    else
        return cellAddress;
}

- (void)initSIPEP{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Sip EP Config" ofType:@"plist"];
    NSMutableDictionary *plistD = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    plistD[@"endpoint"][@"GSDefaultEndpointPolicy"][@"public_address"] = [self getIPAddresses];
    plistD[@"endpoint"][@"basic"][@"connection-udp"][@"user"] = appDelegate.htccUser;
    if (appDelegate.htccConnection.me.wsSettings[@"sipServer"]) {
        plistD[@"endpoint"][@"basic"][@"connection-udp"][@"server"] = appDelegate.htccConnection.me.wsSettings[@"sipServer"];
    }
    else {
        UIAlertViewBlock *alert = [[UIAlertViewBlock alloc] initWithTitle:@"sipServer URL missing"
                                                                  message:@"Please configure sipServer in interaction-workspace option in CME"
                                                               completion:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    NSLog(@"The Endpoint Configuration file is printed below: \n key: endpoint, value: %@", plistD[@"endpoint"]);
    
    sipEP = [GSEndpointFactory sipEndpoint];
    [sipEP configureWithDictionary:plistD[@"endpoint"]];
    sipEP.notificationDelegate = self;
    sipEP.connectionManager.notificationDelegate = self;
    sipEP.sessionManager.notificationDelegate = self;
    [sipEP activate];
}

- (void)closeSIPEP{
    GSResult result = GSResultFailed;
    NSArray *connections = [sipEP.connectionManager allConnections];
    
    for (id<GSConnection> connection in connections) {
        if (connection.state == GSConnectionRegisteredState) {
            result = [connection disable];
            NSLog(@"The Connection: server=%@ transport=%@ user=%@ is unregistered with result %d.", connection.server, connection.transport, connection.user, result);
        }
    }
}

- (void) connection:(id<GSConnection>)connection stateDidChangeWithInfo:(NSDictionary *)info {
    
    NSNumber* statusCode = [info objectForKey:responseCodeKeyName];
    NSLog(@"statusCode: %d", [statusCode intValue]);
    NSLog(@"state: %d", connection.state);
    
    if ( connection.state == GSConnectionUnregisteredState && [statusCode intValue] != GSSipSuccessCode ) {
        
        NSNumber *ri = [connection regInterval];
        NSLog(@"Re registration interval: %d.", ri.intValue);
        if (ri.intValue > 0) {
            NSLog(@"Re registration interval > 0.");
            return;
        }
        else if (ri.intValue == 0 ) {
            NSLog(@"Re registration interval = 0.");
        }
        else if (ri.intValue < 0) {
            NSLog(@"Re registration interval < 0.");
        }
    }
}

- (void) sessionStateDidChange:(id<GSSession>) session {
    NSLog(@"The session state changed: %@", session);
}

- (void) endpointStateDidChange {
    if ( sipEP.state == GSEndpointActiveState )
        NSLog(@"Endpoint State: Active");
    else if (sipEP.state == GSEndpointActivatingState )
        NSLog(@"Endpoint State: Activating");
    else if (sipEP.state == GSEndpointInactiveState )
        NSLog(@"Endpoint State: Inactive");
    else if (sipEP.state == GSEndpointDeactivatingState )
        NSLog(@"Endpoint State: Deactivating");
}

#endif

@end

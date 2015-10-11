//
//  LoginViewController.h
//  HTCC Sample
//
//  Created by Arkady on 10/21/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef SIPEP

#import "SipEndpoint.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
@interface LoginViewController : UIViewController <GSEndpointNotificationDelegate, GSConnectionNotificationDelegate, GSSessionNotificationDelegate>

#else

@interface LoginViewController : UIViewController

#endif


@end

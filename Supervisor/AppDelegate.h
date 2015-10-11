//
//  AppDelegate.h
//  Supervisor
//
//  Created by David Beilis on 4/29/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *htccURL;
@property (strong, nonatomic) NSString *htccUser;
@property (strong, nonatomic) NSString *htccPassword;
@property (nonatomic) BOOL sipEnabled;
@property (nonatomic) BOOL eServicesEnabled;
@property (nonatomic) BOOL apnEnabled;

@property (strong, nonatomic) ConnectionController *htccConnection;

@property (strong, nonatomic) NSString *notifyToken;


@end


//
//  AppDelegate.m
//  Supervisor
//
//  Created by David Beilis on 4/29/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#define kHTCCURL            @"htccURL"
#define kHTCCUser           @"htccUser"
#define kHTCCPassword       @"htccPassword"
#define kSipEnabled         @"sipEnabled"
#define kEServicesEnabled   @"eServicesEnabled"
#define kapnEnabled         @"apnEnabled"

#pragma mark - User Defaults

// we are being notified that our preferences have changed (user changed them in the Settings app)
// so read in the changes and update our UI.
//
- (void)defaultsChanged:(NSNotification *)notif {
    [self initDefaults];
    _htccConnection = [ConnectionController createWithURL:_htccURL];
}

- (void)initDefaults {
    _htccURL = [[NSUserDefaults standardUserDefaults] stringForKey:kHTCCURL];
    _htccUser = [[NSUserDefaults standardUserDefaults] stringForKey:kHTCCUser];
    _htccPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kHTCCPassword];
    _sipEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSipEnabled];
    _eServicesEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kEServicesEnabled];
    _apnEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kapnEnabled];
    
    if (_htccURL == nil)
    {
        // no default values have been set, create them here based on what's in our Settings bundle info
        NSString *finalPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"];
        
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
        NSDictionary *prefItem;
        for (prefItem in prefSpecifierArray)
        {
            NSString *keyValueStr = [prefItem objectForKey:@"Key"];
            id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            
            if ([keyValueStr isEqualToString:kHTCCURL]) {
                _htccURL = defaultValue;
            }
            if ([keyValueStr isEqualToString:kSipEnabled]) {
                _sipEnabled = [defaultValue boolValue];
            }
            if ([keyValueStr isEqualToString:kEServicesEnabled]) {
                _eServicesEnabled = [defaultValue boolValue];
            }
            if ([keyValueStr isEqualToString:kapnEnabled]) {
                _apnEnabled = [defaultValue boolValue];
            }
        }
        
        _htccUser = @"";
        _htccPassword = @"";
        
        // since no default values have been set (i.e. no preferences file created), create it here
        NSDictionary *appDefaults = @{kHTCCURL: _htccURL, kHTCCUser: _htccUser, kHTCCPassword: _htccPassword,
                                      kSipEnabled: @(_sipEnabled), kEServicesEnabled: @(_eServicesEnabled), kapnEnabled: @(_apnEnabled)};
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) saveDefaults {
    // Unregister from NSUserDefaultsDidChangeNotification, so we don't get it when defaults are being saved
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Update user defaults
    [[NSUserDefaults standardUserDefaults] setObject:_htccURL forKey:kHTCCURL];
    [[NSUserDefaults standardUserDefaults] setObject:_htccUser forKey:kHTCCUser];
    [[NSUserDefaults standardUserDefaults] setObject:_htccPassword forKey:kHTCCPassword];
    [[NSUserDefaults standardUserDefaults] setBool:_sipEnabled forKey:kSipEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:_eServicesEnabled forKey:kEServicesEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:_apnEnabled forKey:kapnEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // listen for changes to our preferences when the Settings app does so,
    // when we are resumed from the backround, this will give us a chance to update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

#pragma mark - App Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if TARGET_OS_IPHONE
    NSLog(@"Registering for push notifications...");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
#endif
    
    //Update Version number in Settings
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:appVersionString forKey:@"currentVersionKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set the application defaults
    [self initDefaults];
    
    // Init Connection Controller
    _htccConnection = [ConnectionController createWithURL:_htccURL];
    
    //    if (launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
    //        //App was lunched with Push Notification
    //        [self processAPN:launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
    //    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state. Use this method to pause
    // ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
    // Games should use this method to pause the game.
    
    if (_htccConnection.me.loggedIn) {
        // Executing a Finite-Length Task in the Background
        UIBackgroundTaskIdentifier __block bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Do the work associated with the task, preferably in chunks.
            //Disconnect from Comet and don't expect the ack
            [_htccConnection unsubscribeFromAllChannels];
            [_htccConnection disconnectSynchronous];
            
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application to its
    // current state in case it is terminated later. If your application supports
    // background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveDefaults];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (_htccConnection.me.loggedIn) {
        //Handshake CometD. Then Subsribe to channels.
        _htccConnection.subscribtionDoneAction = nil;
        [_htccConnection handshake];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveDefaults];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *str  = [NSString stringWithFormat:@"%@", deviceToken];
    
    _notifyToken = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    _notifyToken = [_notifyToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _notifyToken = [_notifyToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"Notification token: %@", _notifyToken);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error registering for APN: %@", err);
}

@end

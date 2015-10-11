//
//  CallsPageViewController.m
//  HTCC Sample
//
//  Created by Arkady on 12/2/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "CallsPageViewController.h"
#import "TargetSelectTableViewController.h"
#import "Device.h"
#import "AppDelegate.h"
#import "NSArray+HTCC.h"

@implementation CallsPageViewController {
    // instance variables declared in implementation context
    NSMutableArray *callViewControllers;        //First object is Nav-TargetSelectViewController, then Nav-CallViewController(s)
}

#pragma mark - View Lifecycle

//Register for notification (for Call Status updates) when view is loaded from storyboard
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        //Add this as an observer for Call Status change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callChanged:) name:kUpdateCallNotification object:nil];
        //Add this as an observer for AttachedData change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachedDataChanged:) name:kUpdateCallUserDataNotification object:nil];
        //Add this as an observer for ParticipantsUpdated change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantsChanged:) name:kUpdateCallParticipantsNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCallInfo:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    TargetSelectTableViewController *tvc = (TargetSelectTableViewController *)[callViewControllers[0] topViewController];
    tvc.operationBlock = ^(NSString *dest){
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        Device *device = (Device *)appDelegate.htccConnection.me.devices[0];
        [appDelegate.htccConnection submit2HTCC:[NSString stringWithFormat:@"%@%@/calls", kMeDevicesURL, device.deviceID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Dial", @"destination" : @{@"phoneNumber" : dest}}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
        
    };
    tvc.opsType = voice;
    tvc.navTitle = @"New Call";
    
    if (callViewControllers) {
        //After successful comet subscribtion, UIApplicationDidBecomeActiveNotification should be posted.
        //If comet failes, then callViewControllers are not initialized.
        [self setViewControllers:@[callViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Call Info Update

- (void)updateCallInfo:(NSNotification *)notificaton
{
    //Update current call info after app became active. Call may have become established or released while app was inactive.
 
    //We might get callChanged notification before viewDidLoad (incoming call before view was displayed), so we lazy init callViewControllers
    //First object is Nav-TargetSelectViewController, then Nav-CallViewController(s)
    if (callViewControllers == nil) {
        UINavigationController *tnav = [self.storyboard instantiateViewControllerWithIdentifier:@"targetSelectNavViewController"];
        callViewControllers = [NSMutableArray arrayWithObject:tnav];
    }
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.loggedIn) {
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:@"?fields=*"]
                                         method:@"GET"
                                         params:nil
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:^(NSDictionary *response) {
                                  if ([response[@"calls"] isKindOfClass:[NSArray class]] && [response[@"calls"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                      if ([response[@"calls"] count] || appDelegate.htccConnection.me.calls.count) {
                                          //There are active calls or past calls left overs
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              //Mark "Released" for calls that are no longer present
                                              NSArray *newIDs = [response[@"calls"] valueForKey:@"id"];
                                              [appDelegate.htccConnection.me.calls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  if (![newIDs containsObject:((Interaction *)obj).ixnID]) {
                                                      // Call is gone, simulate "Release"
                                                      [(Interaction *)appDelegate.htccConnection.me.calls[idx] updateFromDict:@{@"state": @"Released"}];
                                                      NSNotification *notification = [NSNotification notificationWithName:kUpdateCallNotification object:self userInfo:@{@"index": @(idx)}];
                                                      [self callChanged:notification];
                                                  }
                                              }];
                                              
                                              //Process new or existing calls
                                              [response[@"calls"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.calls
                                                                                    newInteraction:obj
                                                                                      notification:kUpdateCallNotification
                                                                                          userInfo:notificaton.userInfo];
                                                  [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.calls
                                                                                    newInteraction:obj
                                                                                      notification:kUpdateCallParticipantsNotification
                                                                                          userInfo:notificaton.userInfo];
                                                  [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.calls
                                                                                    newInteraction:obj
                                                                                      notification:kUpdateCallUserDataNotification
                                                                                          userInfo:notificaton.userInfo];
                                              }];
                                          });
                                      }
                                  }
                              }];
    }
}

#pragma mark Notifications

- (void)selectTabBar:(UIViewController *)vc
{
    if (vc) {
        if (self.tabBarController.selectedViewController != vc) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPopoverPadNotification object:self];
            self.tabBarController.selectedViewController = vc;
        }
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPopoverPadNotification object:self];
        self.tabBarController.selectedIndex = 0;
    }
}

- (void)callChanged:(NSNotification *)notificaton
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger idx = [notificaton.userInfo[@"index"] integerValue];
    if (idx == NSNotFound) {
        //New call - create new CallViewController
        idx = appDelegate.htccConnection.me.calls.count - 1;
        //Ignore any states except "Ringing", "Preview" or empty ID for new calls, when user is logged in
        //Accept any state for existing calls after app launches and user logs in (userInfo[@"afterLogin"] is TRUE)
        if ((![((Interaction *)appDelegate.htccConnection.me.calls[idx]).state isEqualToString:@"Ringing"] &&
            ![((Interaction *)appDelegate.htccConnection.me.calls[idx]).state isEqualToString:@"Preview"] &&
            ![((Interaction *)appDelegate.htccConnection.me.calls[idx]).state isEqualToString:@"Dialing"] &&
            ![notificaton.userInfo[@"afterLogin"] boolValue]) ||
            ((Interaction *)appDelegate.htccConnection.me.calls[idx]).ixnID.length == 0) {
            NSLog(@"Removing call ixnID: %@, at index: %tu, from me.calls (%p)", [[appDelegate.htccConnection.me.calls lastObject] ixnID], appDelegate.htccConnection.me.calls.count, appDelegate.htccConnection.me.calls);
            [appDelegate.htccConnection.me.calls removeLastObject];
            return;
        }
        [self selectTabBar:self];
        UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"callNavController"];
        NSLog(@"Adding callViewController: %p, at index: %tu", nvc, callViewControllers.count);
        [callViewControllers addObject:nvc];
        if ([((Interaction *)appDelegate.htccConnection.me.calls[idx]).callType isEqualToString:@"Consult"] &&
            ((Interaction *)appDelegate.htccConnection.me.calls[idx]).uri &&
            ((Interaction *)appDelegate.htccConnection.me.calls[idx]).parentCallUri) {
            //Save Consult URI as a key and Parent URI as a value in consultCallIDs
            [appDelegate.htccConnection.me.consultCallURIs setObject:((Interaction *)appDelegate.htccConnection.me.calls[idx]).parentCallUri forKey:((Interaction *)appDelegate.htccConnection.me.calls[idx]).uri];
        }
        __weak UIPageViewController *mySelf = self;
        [self setViewControllers:@[nvc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            if(finished)
            {
                // bug fix for uipageview controller
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mySelf setViewControllers:@[nvc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                });
            }
        }];
    }
    [self selectTabBar:self];
    CallViewController *cvc = [callViewControllers[idx + 1] viewControllers][0];
    cvc.pageVCdelegate = (id <CallDelegate>)self;
    cvc.ixn = appDelegate.htccConnection.me.calls[idx];
    [cvc callChanged];
}

- (CallViewController *)callVCHelper:(NSInteger)idx
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self selectTabBar:self];
    if (idx == NSNotFound || ((Interaction *)appDelegate.htccConnection.me.calls[idx]).ixnID.length == 0) {
        //id of call that hasn't started was received from server, ignore it
        NSLog(@"Removing call ixnID: %@, at index: %tu, from me.calls (%p)", [[appDelegate.htccConnection.me.calls lastObject] ixnID], appDelegate.htccConnection.me.calls.count, appDelegate.htccConnection.me.calls);
        [appDelegate.htccConnection.me.calls removeLastObject];
        return nil;
    }
    CallViewController *cvc = [callViewControllers[idx + 1] viewControllers][0];
    cvc.ixn = appDelegate.htccConnection.me.calls[idx];
    return cvc;
}

- (void)attachedDataChanged:(NSNotification *)notificaton
{
    CallViewController *cvc = [self callVCHelper:[notificaton.userInfo[@"index"] integerValue]];
    [cvc attachedDataChanged];
}

- (void)participantsChanged:(NSNotification *)notificaton
{
    CallViewController *cvc = [self callVCHelper:[notificaton.userInfo[@"index"] integerValue]];
    [cvc participantsChanged];
}

- (void)callMarkedDone:(Interaction *)ixn
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger callIndex = [appDelegate.htccConnection.me.calls indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:ixn];
    }];
    
    [appDelegate.htccConnection.me.consultCallURIs removeObjectForKey:ixn.uri];
    NSArray *parentKeys = [appDelegate.htccConnection.me.consultCallURIs allKeysForObject:ixn.uri];
    [appDelegate.htccConnection.me.consultCallURIs removeObjectsForKeys:parentKeys];
    NSLog(@"Removing call ixnID: %@, at index: %zd, from me.calls (%p)", [appDelegate.htccConnection.me.calls[callIndex] ixnID], callIndex, appDelegate.htccConnection.me.calls);
    [appDelegate.htccConnection.me.calls removeObjectAtIndex:callIndex];
    NSLog(@"Removing callViewController: %p, at index: %zd", callViewControllers[callIndex + 1], callIndex + 1);
    [callViewControllers removeObjectAtIndex:callIndex + 1];

    __weak UIPageViewController *mySelf = self;
    __weak NSArray *myCVCs = callViewControllers;
    [self setViewControllers:@[callViewControllers.lastObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        if(finished)
        {
            // bug fix for uipageview controller
            dispatch_async(dispatch_get_main_queue(), ^{
                [mySelf setViewControllers:@[myCVCs.lastObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            });
        }
    }];
}

- (void)showParentCall:(Interaction *)ixn
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger callIndex = [appDelegate.htccConnection.me.calls indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:ixn];
    }];
    NSString *parentURI = appDelegate.htccConnection.me.consultCallURIs[ixn.uri];
    NSInteger idx = [appDelegate.htccConnection.me.calls indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [((Interaction *)obj).uri isEqualToString:parentURI];
    }];
    if (idx != NSNotFound) {
        UIPageViewControllerNavigationDirection dir = (idx > callIndex) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        __weak UIPageViewController *mySelf = self;
        __weak NSArray *myCVCs = callViewControllers;
        [self setViewControllers:@[callViewControllers[idx + 1]] direction:dir animated:YES completion:^(BOOL finished) {
            if(finished)
            {
                // bug fix for uipageview controller
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mySelf setViewControllers:@[myCVCs[idx + 1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                });
            }
        }];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [callViewControllers indexOfObject:viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return callViewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [callViewControllers indexOfObject:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == callViewControllers.count) {
        return nil;
    }
    return callViewControllers[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return callViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (pageViewController.viewControllers.count == 0)
        return 0;
    
    NSInteger idx = [callViewControllers indexOfObject:[pageViewController.viewControllers lastObject]];
    return (idx == NSNotFound) ? 0 : idx;
}

@end

//
//  EmailsPageViewController.m
//  HTCC Sample
//
//  Created by Arkady on 3/12/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "EmailsPageViewController.h"
#import "AppDelegate.h"
#import "Interaction.h"
#import "EmailComposeTableViewController.h"
#import "NSArray+HTCC.h"


@implementation EmailsPageViewController {
    // instance variables declared in implementation context
    NSMutableArray *emailViewControllers;
}


#pragma mark - View Lifecycle

//Register for notification (for Call Status updates) when view is loaded from storyboard
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        //Add observers for Email change notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailStatusChanged:) name:kUpdateEmailStatusNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailUserDataChanged:) name:kUpdateEmailUserDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEmailInfo:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        emailViewControllers = [NSMutableArray arrayWithCapacity:1];
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Email Info Update

- (void)updateEmailInfo:(NSNotification *)notificaton
{
    //Update current email info after app became active
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.loggedIn && appDelegate.eServicesEnabled) {
        [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:@"?fields=*"]
                                         method:@"GET"
                                         params:nil
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:^(NSDictionary *response) {
                                  if ([response[@"emails"] count] || appDelegate.htccConnection.me.emails.count) {
                                      if ([response[@"emails"] isKindOfClass:[NSArray class]] && [response[@"emails"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                          //Check for emails that have been released
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              //Mark "Revoked" for emails that are no longer present
                                              NSArray *newIDs = [response[@"emails"] valueForKey:@"id"];
                                              [appDelegate.htccConnection.me.emails enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  if (![newIDs containsObject:((Interaction *)obj).ixnID]) {
                                                      // Email is gone, simulate "Revoked"
                                                      [(Interaction *)appDelegate.htccConnection.me.emails[idx] updateFromDict:@{@"state": @"Revoked"}];
                                                      NSNotification *notification = [NSNotification notificationWithName:kUpdateEmailStatusNotification object:self userInfo:@{@"index": @(idx)}];
                                                      [self emailStatusChanged:notification];
                                                  }
                                              }];
                                              if ([response[@"emails"] count]) {
                                                  //Process new or existing emails
                                                  [response[@"emails"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                      if ([obj[@"state"] isEqualToString:@"Invited"] || [obj[@"state"] isEqualToString:@"Processing"]) {
                                                          [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.emails newInteraction:obj notification:kUpdateEmailStatusNotification userInfo:notificaton.userInfo];
                                                          [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.emails newInteraction:obj notification:kUpdateEmailUserDataNotification userInfo:notificaton.userInfo];
                                                      }
                                                  }];
                                                  //Process "Composing" emails
                                                  [response[@"emails"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                      if ([obj[@"state"] isEqualToString:@"Composing"]) {
                                                          [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.emails newInteraction:obj notification:kUpdateEmailStatusNotification userInfo:notificaton.userInfo];
                                                      }
                                                  }];
                                             }
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
        self.tabBarItem.enabled = YES;
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
        self.tabBarItem.enabled = NO;
        self.tabBarController.selectedIndex = 0;
    }
}

- (void)updateIxn:(NSInteger)idx initView:(BOOL)initView
{
    //Update existing interaction
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self selectTabBar:self];
    EmailViewController *cvc = [emailViewControllers[idx] viewControllers][0];
    cvc.pageVCdelegate = (id <EmailDelegate>)self;
    cvc.ixn = appDelegate.htccConnection.me.emails[idx];
    if (initView)
        [cvc view];         //To init outlets
    [cvc emailStatusChanged];
}

- (void)emailStatusChanged:(NSNotification *)notificaton
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger idx = [notificaton.userInfo[@"index"] integerValue];
    if (idx == NSNotFound) {
        idx = appDelegate.htccConnection.me.emails.count - 1;
        // Check if need to ignore new ixn
        Interaction *newIxn = (Interaction *)appDelegate.htccConnection.me.emails[idx];
        if ((![newIxn.state isEqualToString:@"Invited"] &&
             
            !([newIxn.state isEqualToString:@"Composing"] &&
            newIxn.emailParentID &&
            [[appDelegate.htccConnection.me.emails valueForKey:@"ixnID"] containsObject:newIxn.emailParentID]) &&
             
             ![notificaton.userInfo[@"afterLogin"] boolValue]) ||
            
            newIxn.ixnID.length == 0) {
            
            NSLog(@"Removing email ixnID: %@, at index: %tu, from me.emails (%p)", [[appDelegate.htccConnection.me.emails lastObject] ixnID], appDelegate.htccConnection.me.emails.count, appDelegate.htccConnection.me.emails);
            [appDelegate.htccConnection.me.emails removeLastObject];
            return;
        }
        
        [self selectTabBar:self];
        if ([newIxn.state isEqualToString:@"Composing"]) {
            //New composing email - create new EmailComposeTableViewController
            NSUInteger parentIndex = [appDelegate.htccConnection.me.emails indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [((Interaction *)obj).ixnID isEqualToString:newIxn.emailParentID];
            }];
            if (parentIndex != NSNotFound) {
                EmailComposeTableViewController *emailComposeTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailComposeTableViewController"];
                emailComposeTVC.ixn = newIxn;
                [emailViewControllers[parentIndex] pushViewController:emailComposeTVC animated:YES];
            }
            return;
        }
        else {
            //New incoming email - create new EmailViewController
            UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"emailNavController"];
            NSLog(@"Adding emailViewController: %p, at index: %tu", nvc, emailViewControllers.count);
            [emailViewControllers addObject:nvc];
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
            [self updateIxn:idx initView:YES];
            return;
        }
    }
    else if ([((Interaction *)appDelegate.htccConnection.me.emails[idx]).state isEqualToString:@"Canceled"] ||
             [((Interaction *)appDelegate.htccConnection.me.emails[idx]).state isEqualToString:@"Sent"]) {
        NSLog(@"Removing email ixnID: %@, at index: %zd, from me.emails (%p)", [appDelegate.htccConnection.me.emails[idx] ixnID], idx, appDelegate.htccConnection.me.emails);
        [appDelegate.htccConnection.me.emails removeObjectAtIndex:idx];
        return;
    }
    else if (![((Interaction *)(appDelegate.htccConnection.me.emails[idx])).state isEqualToString:@"Composing"])
        //Ignore "Composing" emails updates
        [self updateIxn:idx initView:NO];
}
- (void)emailUserDataChanged:(NSNotification *)notificaton
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger idx = [notificaton.userInfo[@"index"] integerValue];
    [self selectTabBar:self];
    if (idx == NSNotFound || ((Interaction *)appDelegate.htccConnection.me.emails[idx]).ixnID.length == 0) {
        //id of interaction that hasn't started was received from server, ignore it
        NSLog(@"Removing email ixnID: %@, at index: %tu, from me.emails (%p)", [[appDelegate.htccConnection.me.emails lastObject] ixnID], appDelegate.htccConnection.me.emails.count, appDelegate.htccConnection.me.emails);
        [appDelegate.htccConnection.me.emails removeLastObject];
    }
    else {
        EmailViewController *cvc = [emailViewControllers[idx] viewControllers][0];
        cvc.ixn = appDelegate.htccConnection.me.emails[idx];
        [cvc emailUserDataChanged];
    }
}

- (void)emailMarkedDone:(Interaction *)ixn
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger emailIndex = [appDelegate.htccConnection.me.emails indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:ixn];
    }];
    
    NSLog(@"Removing email ixnID: %@, at index: %zd, from me.emails (%p)", [appDelegate.htccConnection.me.emails[emailIndex] ixnID], emailIndex, appDelegate.htccConnection.me.emails);
    [appDelegate.htccConnection.me.emails removeObjectAtIndex:emailIndex];
    NSLog(@"Removing emailViewController: %p, at index: %zd", emailViewControllers[emailIndex], emailIndex);
    [emailViewControllers removeObjectAtIndex:emailIndex];
    
    if (appDelegate.htccConnection.me.emails.count) {
        //There are active emails - display previous
        __weak UIPageViewController *mySelf = self;
        __weak NSArray *myCVCs = emailViewControllers;
        [self setViewControllers:@[emailViewControllers.lastObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            if(finished)
            {
                // bug fix for uipageview controller
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mySelf setViewControllers:@[myCVCs.lastObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                });
            }
        }];
    }
    else {
        //No active emails
        [self selectTabBar:nil];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [emailViewControllers indexOfObject:viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return emailViewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [emailViewControllers indexOfObject:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == emailViewControllers.count) {
        return nil;
    }
    return emailViewControllers[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return emailViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (pageViewController.viewControllers.count == 0)
        return 0;
    
    NSInteger idx = [emailViewControllers indexOfObject:[pageViewController.viewControllers lastObject]];
    return (idx == NSNotFound) ? 0 : idx;
}

@end

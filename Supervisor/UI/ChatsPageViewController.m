//
//  ChatsPageViewController.m
//  HTCC Sample
//
//  Created by Arkady on 12/17/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "ChatsPageViewController.h"
#import "AppDelegate.h"
#import "Interaction.h"
#import "NSArray+HTCC.h"

@implementation ChatsPageViewController  {
    // instance variables declared in implementation context
    NSMutableArray *chatViewControllers;
}


#pragma mark - View Lifecycle

//Register for notification (for Call Status updates) when view is loaded from storyboard
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        //Add observers for Chat change notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatStatusChanged:) name:kUpdateChatStatusNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatParticipantsChanged:) name:kUpdateChatParticipantsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatUserDataChanged:) name:kUpdateChatUserDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessagesChanged:) name:kUpdateChatMessagesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatInfo:) name:UIApplicationDidBecomeActiveNotification object:nil];
        chatViewControllers = [NSMutableArray arrayWithCapacity:1];
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
#pragma mark - Chat Info Update

- (void)updateChatInfo:(NSNotification *)notificaton
{
    //Update chat info after app became active
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.loggedIn && appDelegate.eServicesEnabled) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:@"?fields=*"]
                                         method:@"GET"
                                         params:nil
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:^(NSDictionary *response) {
                                  if ([response[@"chats"] count] || appDelegate.htccConnection.me.chats.count) {
                                      if ([response[@"chats"] isKindOfClass:[NSArray class]] && [response[@"chats"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                          //Check if there are chats that have been released
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              //Mark "Revoked" for chats that are no longer present
                                              NSArray *newIDs = [response[@"chats"] valueForKey:@"id"];
                                              [appDelegate.htccConnection.me.chats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  if (![newIDs containsObject:((Interaction *)obj).ixnID]) {
                                                      // Chat is gone, simulate "Revoked"
                                                      [(Interaction *)appDelegate.htccConnection.me.chats[idx] updateFromDict:@{@"state": @"Revoked"}];
                                                      NSNotification *notification = [NSNotification notificationWithName:kUpdateChatStatusNotification object:self userInfo:@{@"index": @(idx)}];
                                                      [self chatStatusChanged:notification];
                                                  }
                                              }];
                                              //Process new or existing chats
                                              [response[@"chats"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  if ([obj[@"id"] isKindOfClass:[NSString class]] ) {
                                                      NSString *chatID = obj[@"id"];
                                                      [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.chats newInteraction:obj notification:kUpdateChatStatusNotification userInfo:notificaton.userInfo];
                                                      NSUInteger idx = [appDelegate.htccConnection.me.chats indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                          return ([((Interaction *)obj).ixnID isEqualToString:chatID]);
                                                      }];
                                                      ChatViewController *cvc = [chatViewControllers[idx] viewControllers][0];
                                                      cvc.chatActive = YES;
                                                      //Retrieve chat transcript
                                                      [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingFormat:@"%@/messages", chatID]
                                                                                       method:@"GET"
                                                                                       params:nil
                                                                                         user:appDelegate.htccUser
                                                                                     password:appDelegate.htccPassword
                                                                            completionHandler:^(NSDictionary *response) {
                                                                                if ([response[@"messages"] isKindOfClass:[NSArray class]] &&
                                                                                    [response[@"messages"] count]) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        //There is no chatID in response, so we need to update interaction here
                                                                                        ChatViewController *cvc = [chatViewControllers[idx] viewControllers][0];
                                                                                        [cvc clearChatTranscript];
                                                                                        [(Interaction *)appDelegate.htccConnection.me.chats[idx] updateFromDict:response];
                                                                                        NSNotification *notification = [NSNotification notificationWithName:kUpdateChatMessagesNotification object:self userInfo:@{@"index": @(idx)}];
                                                                                        [self chatMessagesChanged:notification];
                                                                                    });
                                                                                }
                                                                                //Update participants and user data
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.chats newInteraction:obj notification:kUpdateChatParticipantsNotification userInfo:notificaton.userInfo];
                                                                                    [appDelegate.htccConnection.me updateInteraction:appDelegate.htccConnection.me.chats newInteraction:obj notification:kUpdateChatUserDataNotification userInfo:notificaton.userInfo];
                                                                                });
                                                      }];
                                                    
                                                  }
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

- (void)chatStatusChanged:(NSNotification *)notificaton
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger idx = [notificaton.userInfo[@"index"] integerValue];
    if (idx == NSNotFound) {
        idx = appDelegate.htccConnection.me.chats.count - 1;
        // Ignore any states except "Invited" or empty ID for new interactions
        // Accept any state for existing chats after app launches and user logs in (userInfo[@"afterLogin"] is TRUE)
        if ((![((Interaction *)appDelegate.htccConnection.me.chats[idx]).state isEqualToString:@"Invited"] &&
             ![notificaton.userInfo[@"afterLogin"] boolValue]) ||
            ((Interaction *)appDelegate.htccConnection.me.chats[idx]).ixnID.length == 0) {
            NSLog(@"Removing chat ixnID: %@, at index: %tu, from me.chats (%p)", [[appDelegate.htccConnection.me.chats lastObject] ixnID], appDelegate.htccConnection.me.chats.count, appDelegate.htccConnection.me.chats);
            [appDelegate.htccConnection.me.chats removeLastObject];
            return;
        }
        [self selectTabBar:self];
        //New chat - create new ChatViewController
        UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavController"];
        NSLog(@"Adding chatViewController: %p, at index: %tu", nvc, chatViewControllers.count);
        [chatViewControllers addObject:nvc];
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
    ChatViewController *cvc = [chatViewControllers[idx] viewControllers][0];
    cvc.pageVCdelegate = (id <ChatDelegate>)self;
    cvc.ixn = appDelegate.htccConnection.me.chats[idx];
    [cvc chatStatusChanged];
}

- (ChatViewController *)chatVCHelper:(NSInteger)idx
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self selectTabBar:self];
    if (idx == NSNotFound || ((Interaction *)appDelegate.htccConnection.me.chats[idx]).ixnID.length == 0) {
        //id of interaction that hasn't started was received from server, ignore it
        NSLog(@"Removing chat ixnID: %@, at index: %tu, from me.chats (%p)", [[appDelegate.htccConnection.me.chats lastObject] ixnID], appDelegate.htccConnection.me.chats.count, appDelegate.htccConnection.me.chats);
        [appDelegate.htccConnection.me.chats removeLastObject];
        return nil;
    }
    ChatViewController *cvc = [chatViewControllers[idx] viewControllers][0];
    cvc.ixn = appDelegate.htccConnection.me.chats[idx];
    return cvc;
}

- (void)chatParticipantsChanged:(NSNotification *)notificaton
{
    ChatViewController *cvc = [self chatVCHelper:[notificaton.userInfo[@"index"] integerValue]];
    [cvc chatParticipantsChanged];
}


- (void)chatUserDataChanged:(NSNotification *)notificaton
{
    ChatViewController *cvc = [self chatVCHelper:[notificaton.userInfo[@"index"] integerValue]];
    [cvc chatUserDataChanged];
}

- (void)chatMessagesChanged:(NSNotification *)notificaton
{
    ChatViewController *cvc = [self chatVCHelper:[notificaton.userInfo[@"index"] integerValue]];
    [cvc chatMessagesChanged];
}

- (void)chatMarkedDone:(Interaction *)ixn
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger chatIndex = [appDelegate.htccConnection.me.chats indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:ixn];
    }];

    NSLog(@"Removing chat ixnID: %@, at index: %zd, from me.chats (%p)", [appDelegate.htccConnection.me.chats[chatIndex] ixnID], chatIndex, appDelegate.htccConnection.me.chats);
    [appDelegate.htccConnection.me.chats removeObjectAtIndex:chatIndex];
    NSLog(@"Removing chatViewController: %p, at index: %zd", chatViewControllers[chatIndex], chatIndex);
    [chatViewControllers removeObjectAtIndex:chatIndex];

    if (appDelegate.htccConnection.me.chats.count) {
        //There are active chats - display previous
        __weak UIPageViewController *mySelf = self;
        __weak NSArray *myCVCs = chatViewControllers;
        [self setViewControllers:@[chatViewControllers.lastObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
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
        //No active chats
        [self selectTabBar:nil];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [chatViewControllers indexOfObject:viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return chatViewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [chatViewControllers indexOfObject:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == chatViewControllers.count) {
        return nil;
    }
    return chatViewControllers[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return chatViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (pageViewController.viewControllers.count == 0)
        return 0;
    
    NSInteger idx = [chatViewControllers indexOfObject:[pageViewController.viewControllers lastObject]];
    return (idx == NSNotFound) ? 0 : idx;
}

@end

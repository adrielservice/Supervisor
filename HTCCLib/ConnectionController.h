//
//  ConnectionController.h
//  HTCC Sample
//
//  Created by Arkady on 10/22/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Me.h"

#define kUpdateLogNotification              @"HTCCUpdateLogNotification"
#define kUpdateDevicesChannelsNotification  @"HTCCDevicesChannelsNotification"
#define kUpdateCallNotification             @"HTCCCallNotification"
#define kUpdateCallParticipantsNotification @"HTCCCallParticipantsNotification"
#define kUpdateCallUserDataNotification     @"HTCCCallUserDataNotification"
#define kCometdSubscriptionSucceed          @"HTCCCometdSubscriptionSucceed"
#define kUpdateChatStatusNotification       @"HTCCChatStatusNotification"
#define kUpdateChatParticipantsNotification @"HTCCChatParticipantsNotification"
#define kUpdateChatUserDataNotification     @"HTCCChatUserDataNotification"
#define kUpdateChatMessagesNotification     @"HTCCChatMessagesNotification"
#define kUpdateEmailStatusNotification      @"HTCCEmailStatusNotification"
#define kUpdateEmailUserDataNotification    @"HTCCEmailUserDataNotification"
#define kDismissPopoverPadNotification      @"HTCCDismissPopoverPadNotification"

#define kCometURL                           @"/api/v2/notifications"
#define kCometDevicesChannel                @"/v2/me/devices"
#define kCometChannelsChannel               @"/v2/me/channels"
#define kCometCallsChannel                  @"/v2/me/calls"
#define kCometChatChannel                   @"/v2/me/chats"
#define kCometEmailChannel                  @"/v2/me/emails"

#define kCallsURL                           @"/api/v2/me/calls/"
#define kChatsURL                           @"/api/v2/me/chats/"
#define kEmailsURL                          @"/api/v2/me/emails/"
#define kMeURL                              @"/api/v2/me"
#define kMeDevicesURL                       @"/api/v2/me/devices/"
#define kAgentStatesURL                     @"/api/v2/settings/agent-states"
#define kChannelURL                         @"/api/v2/me/channels/"
#define kContactsURL                        @"/api/v2/contacts"
#define kBusinessAttribURL                  @"/internal-api/business-attributes"
#define kStatsURL                           @"/api/v1/stats/"


enum {toHTCC, fromHTCC};
enum {hOk, hParamMissing, hParamInvalid, hForbidden, hIntError, hNotAuth, hNotFound, hPartialOk};

@interface ConnectionController : NSObject 

@property (strong, nonatomic, readonly) Me *me;
@property (strong, nonatomic) void (^subscribtionDoneAction)(void);

+ (instancetype)createWithURL:(NSString *)baseURL;
- (void)startCometd;
- (void)handshake;
- (void)unsubscribeFromAllChannels;
- (void)disconnectSynchronous;
- (void)disconnect;

- (void)submit2HTCC:(NSString *)request
             method:(NSString *)method
             params:(NSDictionary *)params
               user:(NSString *)user
           password:(NSString *)password
  completionHandler:(void (^)(NSDictionary *response))completionHandler;

@end

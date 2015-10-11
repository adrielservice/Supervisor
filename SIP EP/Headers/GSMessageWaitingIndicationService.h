//
//  GSMessageWaitingIndicationService.h
//  SipEndpoint
//
//  Created by valery polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMessageWaitingIndicationSubscription.h"
#import "GSEnums.h"
#import "GSMessageWaitingIndicationNotificationDelegate.h"

@protocol GSMessageWaitingIndicationService <NSObject>

/**
 Subscribe for Mailbox
 
 @param subscription object.
 
 @returns     GSResultOK or GSResultFailed as a result of the operation success or fail.
 */
-(GSResult) subscribeForMailbox:(GSMessageWaitingIndicationSubscription*) subscription;

/**
 UnSubscribe from Mailbox
 
 @param subscription object.
 
 @returns     GSResultOK or GSResultFailed as a result of the operation success or fail.
 */
-(GSResult) unsubscribeForMailbox:(GSMessageWaitingIndicationSubscription*) subscription;

@property (nonatomic, assign) id<GSMessageWaitingIndicationNotificationDelegate> notificationDelegate;

@end

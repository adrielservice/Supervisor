//
//  GSMessageWaitingIndicationNotificationDelegate.h
//  SipEndpoint
//
//  Created by valery polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMessageWaitingIndicationSubscription.h"
#import "GSMessageWaitingIndicationState.h"

@protocol GSMessageWaitingIndicationNotificationDelegate <NSObject>

- (void) state:(GSMessageWaitingIndicationState*) state forSubscription:(GSMessageWaitingIndicationSubscription*) subscription;

@end

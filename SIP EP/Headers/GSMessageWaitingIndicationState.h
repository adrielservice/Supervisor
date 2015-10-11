//
//  GSMessageWaitingIndicationState.h
//  SipEndpoint
//
//  Created by valery polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSConnection.h"
#import "GSMessageWaitingIndicationMessageSummary.h"
#import "GSMessageWaitingIndicationSubscription.h"

@interface GSMessageWaitingIndicationState : NSObject {
@private
    NSString* messagesWaiting;
    GSMessageWaitingIndicationSubscription* subscription;
    NSString* messageSummary;
}

@property (nonatomic, copy) NSString* messagesWaiting;
@property (nonatomic, retain) GSMessageWaitingIndicationSubscription* subscription;
@property (nonatomic, copy) NSString* messageSummary;

- (id)initWithSubscription:(GSMessageWaitingIndicationSubscription*) theSubscription 
           messagesWaiting:(NSString*) theMessagesWaiting 
            messageSummary:(NSString*) theMessageSummary;

@end

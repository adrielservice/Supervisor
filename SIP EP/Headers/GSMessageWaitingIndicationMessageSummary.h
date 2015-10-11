//
//  GSDefaultMessageWaitingIndicationMessageSummary.h
//  SipEndpoint
//
//  Created by valery polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSEnums.h"

@interface GSMessageWaitingIndicationMessageSummary : NSObject {
@private
    int newMessages;
    int oldMessages;
    int urgentNewMessages;
    int urgentOldMessages;
}

@property (nonatomic) int newMessages;
@property (nonatomic) int oldMessages;
@property (nonatomic) int urgentNewMessages;
@property (nonatomic) int urgentOldMessages;

@end

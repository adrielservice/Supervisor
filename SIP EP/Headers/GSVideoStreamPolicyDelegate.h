//
//  GSVideoStreamPolicyDelegate.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSSession.h"

@protocol GSVideoStreamPolicyDelegate <NSObject>

@optional

/**
 Accept Incoming Video for Session
 
 @param session object.
 
 @returns True or False as a result of the operation success or fail.
 */

- (BOOL) acceptIncomingVideoForSession:(id<GSSession>) session;

@end

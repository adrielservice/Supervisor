//
//  GSConnectionNotificationDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The constant defining the key name for the SIP reason of a connection state change
 */
const static NSString* responseReasonKeyName = @"responseReason";

/**
 The constant defining the key name for the SIP code of a connection state change
 */
const static NSString* responseCodeKeyName = @"responseCode";

/**
 This delegate is used to receive connection state change notifications
 */
@protocol GSConnectionNotificationDelegate <NSObject>
@required
/**
 Called when the state of a connection has been changed.
 
 @param connection the connection which has had a state change
 @param info a dictionary containing relevant information about the state change (reason, sip code, etc.) 
 */
- (void) connection:(id<GSConnection>)connection stateDidChangeWithInfo:(NSDictionary *)info;

@end

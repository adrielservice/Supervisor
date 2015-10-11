//
//  GSConnection.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSEnums.h"


/**
 This protocol is implemented by each SIP connection object. Users can determine the parameters for
 the given connection as well as toggle connection state.
 */
@protocol GSConnection <NSObject>

/**
 The connection ID
 */
@property (nonatomic, readonly) int connectionId;

/**
 The current connection state
 */
@property (nonatomic, readonly) GSConnectionState state;

/**
 The server address
 */
@property (nonatomic, readonly, copy) NSString* server;

/**
 The transport protocol to use when communicating with this server. Possible values are "tcp" or "udp"
 */
@property (nonatomic, readonly, copy) NSString* transport;

/**
 The user id for this connection
 */
@property (nonatomic, readonly, copy) NSString* user;

/**
 The period after which registration should expire. A new "REGISTER" request will be sent before expiration.
 The valid value is => 0.
 If this property is not set or negative, the default timeout value is 1800 sec.
 If this property is equal to 0, registration disabled (standalone mode).
 */
@property (nonatomic, retain) NSNumber* registrationTimeout;

/**
 The period after which sip endpoint starts a new registration cycle.
 The valid value is => 0.
 If this property is not set or negative, the default timeout value is 0     means: no new reregister allowed.
 If this property is > 0 means: new reregister allowed and will start after the regInterval.
 The measurement unit is sec.
 */
@property (nonatomic, retain) NSNumber* regInterval;

/**
 Enables the current connection. The connection will be available for SIP message handling upon successful completion.
 
 @returns the result (i.e. success or failure) of performing the operation. Note that the actual connection state will be sent asynchronously.
 */
- (GSResult) enable;

/**
 Disables the current connection
 
 @returns the result (i.e. success or failure) of performing the operation.  Note that the actual connection state will be sent asynchronously.
 */
- (GSResult) disable;

@end

//
//  GSSessionControlService.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/12/11.
//  Copyright (c) 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSConnection.h"
#import "GSSession.h"
#import "GSEnums.h"

@protocol GSSessionControlService <NSObject>

/**
 Sends SIP INVITE to the other party for the connection
 
 @param connection object.
 @param destination address.
 
 @returns the result of the operation.
 */
- (GSResult) dialFrom:(id<GSConnection>)connection to:(NSString*)destination;

/**
 Sends SIP INVITE with video in SDP to the other party for the connection
 
 @param connection object.
 @param destination address.
 
 @returns the result of the operation.
 */
- (GSResult) dialVideoFrom:(id<GSConnection>)connection to:(NSString*)destination;

/**
 Sends SIP Voice Call INVITE with user data header to the other party for the connection
 
 @param connection object.
 @param destination address.
 @param string with user data.
 
 @returns the result of the operation.
 */
- (GSResult) dialFrom:(id<GSConnection>)connection to:(NSString*)destination withData:(NSString*)data;

/**
 Sends SIP Video Call INVITE with user data header to the other party for the connection
 
 @param connection object.
 @param destination address.
 @param string with user data.
 
 @returns the result of the operation.
 */
- (GSResult) dialVideoFrom:(id<GSConnection>)connection to:(NSString*)destination withData:(NSString*)data;

/**
 Sends SIP 200OK to the incoming session
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) answerSession:(id<GSSession>) session;

/**
 Sends SIP 200OK to the incoming video session
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) answerVideoSession:(id<GSSession>) session;

/**
 Sends SIP BYE to the session
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) hangupSession:(id<GSSession>) session;

/**
 Put the session on Hold
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) holdSession:(id<GSSession>) session;

/**
 Retrive the session from Hold
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) retrieveSession:(id<GSSession>) session;

/**
 Helps to create destination address
 
 @param connection object.
 @param string with destination name.
 
 @returns a string with full address to the destination.
 */
- (NSString*)createAddress:connection to:destination;

/**
 Sends DTMF to the other parties in the session. The DTMF method is determined by the policy
 configured for this session's session manager.
 
 @param digits the DTMF digits to be sent. 
 
 @returns the result of the operation.
 */
- (GSResult) sendDtmf:(NSString*) digits forSession:(id<GSSession>) session;

@end

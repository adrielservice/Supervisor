//
//  GSEndopintFactory.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GSEndpoint.h"
#import "GSLogger.h"

/**
 This class is used to create an instance of a sip endpoint. Note that in the current implementation the sip endpoint is a singleton.
 */
@interface GSEndpointFactory : NSObject {
@private

}

/**
 Should be used to create an instance of the sip endpoint.
 
 @returns returns the current sip endpoint. This object can be used to subscribe for endpoint state change notifications. 
 GSDefaultLogger will be used for logging to console.
 @see GSObservable
 @see GSStatusObserver
 @see GSDefaultLogger
 */
+ (id<GSEndpoint>) sipEndpoint;

/**
 Same as sipEndpoint with the added ability to provide a custom logger to be used by the framework.
 
 @param logger an object implementing the GSLogger protocol which will be used to log all messages.
 @returns an instance of the current sip endpoint. 
 @see GSEndpointFactory#sipEndpoint
 */
+ (id<GSEndpoint>) sipEndpointWithLogger:(id<GSLogger>) logger;

/**
 Same as sipEndpoint with the added ability to provide logging to a log file with certain level.
 
 @param logFile: /path/logfilename.log.
 @param logLevel: debug; info; warn; error; fatal.
 @returns an instance of the current sip endpoint.
 @see GSEndpointFactory#sipEndpoint
 */
+ (id<GSEndpoint>) sipEndpointWithLogFile:(NSString*) logFile logLevel:(NSString*) logLevel;

/**
 Same as sipEndpoint with the added ability to provide console logging with certain log level.
 
 @param logLevel: debug; info; warn; error; fatal.
 @returns an instance of the current sip endpoint.
 @see GSEndpointFactory#sipEndpoint
 */
+ (id<GSEndpoint>) sipEndpointWithLogLevel:(NSString*) logLevel;

@end

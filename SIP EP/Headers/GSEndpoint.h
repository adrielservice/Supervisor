//
//  GSEndpoint.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GSEnums.h"
#import "GSLogger.h"
#import "GSConnectionManager.h"
#import "GSSessionManager.h"
#import "GSDeviceManager.h"
#import "GSEndpointNotificationDelegate.h"
#import "GSEndpointPolicyDelegate.h"
#import "GSSessionControlService.h"

/**
 This protocol defines sip endpoint functionality. It should be used to configure the sip endpoint and work with all active
 connections, sessions, and devices.
 */
@protocol GSEndpoint <NSObject>

/**
 Used to provide endpoint ID.
 
 @returns a number that is represent the endpoint ID.
 */
@property (nonatomic) int endpointId;

/**
 Get/set instance of the logger.
 
 @see GSLogger
 */
//@property (nonatomic, retain) id<GSLogger> logger;

/**
 Used to configure all sip endpoint parameters. This method should be called before any other actions are performed.

 @param configuration a dictionary object containing all configuration information.
 */
- (void) configureWithDictionary:(NSDictionary*)configuration;

/**
 Enables all configured connections.
 */
- (void) activate;

/**
 Returns the current endpoint status. The endpoint is considered "Active" if at least one connection is registered.
 */
@property (nonatomic) GSEndpointState state;

/**
 Get/set instance of the connection manager object which handles all connection information, stores all related policies 
 and provides notifications about connection state. Returns a Genesys GSConnectionManager implemenation as the default.
 
 @see GSConnectionManager
 */
@property (nonatomic, retain) id<GSConnectionManager> connectionManager;

/**
 Get/set instance of the session manager object which handles all session data, stores all related policies 
 and provides notifications about session state. Returns a Genesys GSSessionManager implemenation as the default.
 
 @see GSSessionManager
 */
@property (nonatomic, retain) id<GSSessionManager> sessionManager;

/**
 Get/set instance of the device manager object which handles all connected input/output devices, stores all related policies 
 and provides notifications about device state. Returns a Genesys GSDeviceManager implemenation as the default
 
 @see GSDeviceManager
 */
@property (nonatomic, retain) id<GSDeviceManager> deviceManager;

/**
 Get/set the delegate responsible for notifications about endpoint state.
 */
@property (nonatomic, assign) id<GSEndpointNotificationDelegate> notificationDelegate;

/**
 Get/set the delegate responsible for dictating endpoint policy.
 */
@property (nonatomic, assign) id<GSEndpointPolicyDelegate> policyDelegate;

/**
 Get/set the delegate responsible for dictating endpoint policy.
 */
@property (nonatomic, assign) id<GSDevicePolicyDelegate> devicePolicyDelegate;

/**
 @returns  an instance of the session control service to be used for first party call control
 */
- (id<GSSessionControlService>) sessionControlService;

/**
 @returns  an instance of the media statistics service to be used for first party call control
 */
- (id<GSStatisticsService>) statisticsService;
@end

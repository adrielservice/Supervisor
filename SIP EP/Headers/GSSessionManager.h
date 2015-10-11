//
//  GSSessionManager.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "GSConnection.h"
#import "GSSessionNotificationDelegate.h"
#import "GSSessionPolicyDelegate.h"
#import "GSDevicePolicyDelegate.h"
#import "GSStatisticsNotificationDelegate.h"
#import "GSStatisticsService.h"

/**
 This protocol defines the functionality of a session manager which is responsible for handling all sessions. This object provides
 lists of current active sessions, some search functionality, as well as the ability to configure policy and receive notifications
 regarding session state.
 */
@protocol GSSessionManager <NSObject>

@property (nonatomic) int endpointId;

/**
 Returns a list of active sessions currently monitored by the session manager. 
 
 @returns an array of id<GSSession> objects
 */
- (NSArray*) allSessions;

/**
 Returns a list of active sessions established over the specified connection.
 
 @param connection the connection for which to retrieve the sessions 
 
 @return an array of id<GSSession> objects
 */
- (NSArray*) sessionsForConnection:(id<GSConnection>) connection;

/**
 Get/set the delegate to be notified about sessions state.
 */
@property (nonatomic, assign) id<GSSessionNotificationDelegate> notificationDelegate;

/**
 Get/set the policy which defines aspects of session behavior. 
 */
@property (nonatomic, assign) id<GSSessionPolicyDelegate> policyDelegate;

/**
 Get/set the delegate to be notified about sessions statistics.
 */
@property (nonatomic, assign) id<GSStatisticsNotificationDelegate> statisticsNotificationDelegate;

/**
 @returns  an instance of the Statistics Service to be used for get statistics functionality
 */
- (id<GSStatisticsService>) statisticsService;

/**
 Get/set the policy which defines AGC mode for session.
 */
- (GSResult) setAgcMode:(int) agcMode;

/**
 Get/set the policy which defines AGC mode for session.
 */
- (GSResult) setDtxMode:(int) dtxMode vadLevel:(int) vadLevel;

@end

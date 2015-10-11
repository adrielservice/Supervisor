//
//  GSConnectionManager.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSConnection.h"
#import "GSConnectionNotificationDelegate.h"
#import "GSConnectionPolicyDelegate.h"
#import "GSMessageWaitingIndicationService.h"
#import "GSMessageWaitingIndicationNotificationDelegate.h"

//vpolishc
#if !TARGET_OS_IPHONE
#import "GSVideoService.h"
#import "GSVideoStreamNotificationDelegate.h"
#import "GSVideoStreamPolicyDelegate.h"
#endif


/**
 This protocol defines connection manager functionality. Note: all NSArrays returned by this protocol's methods hold objects of type 
 id<GSConnection>. 
 */
@protocol GSConnectionManager <NSObject>

@property (nonatomic) int endpointId;

/**
 Adds a new connection
 
 @param user the user id
 @param server the server address
 @param transport the transport protocol (valid values are 'tcp' or 'udp')
 
 @returns a newly created connection object or nil if the operation is not successful.
 */
- (id<GSConnection>) addConnectionForUser:(NSString*) user server:(NSString*) server transport:(NSString*) transport;

/**
 Removes (and disables) the specified connection.
 
 @param connection the connection to remove (note that the connection object must not be a copy).
 */
- (void) removeConnection:(id<GSConnection>) connection;

/**
 Utility method to retrieve a snapshot of current connections for the specified user id, server and transport. Note that passing 'nil' 
 for any parameter is acceptable and means that the parameter will be excluded from the condition. For instance: 
 [myInstance connectionsForUser:@"user1" toServer:@"server1" withTransport:nil] will return either tcp or udp connections to the specified
 server for the specified user.
 
 @param user the user id for the connection
 @param server the server address
 @param transport the transport protocol
 
 @returns a list of all connections matching the specified criteria
 */
- (NSArray*) connectionsForUser:(NSString*) user toServer:(NSString*) server withTransport:(NSString*) transport;

/**
 Utility method to retrieve a snapshot of current connections for the specified user id and server.
 
 @param user the user id for the connection
 @param server the server address
 
 @returns a list of all connections matching the specified criteria
 */
- (NSArray*) connectionsForUser:(NSString*) user toServer:(NSString*) server;

/**
 Utility method to retrieve a snapshot of current connections to the specified server.
 
 @param server the server address
 
 @returns a list of all connections to the specified server
 */
- (NSArray*) connectionsToServer:(NSString*) server;

/**
 Utility method to retrieve a snapshot of current connections with the specified transport to the given server.
 
 @param server the server address
 @param transport the transport protocol
 
 @returns a list of all connections matching the specified criteria
 */
- (NSArray*) connectionsToServer:(NSString*) server withTransport:(NSString*) transport;

/**
 @returns a snapshot of current connections
 */
- (NSArray*) allConnections;

/**
 @returns a snapshot of current subscriptions
 */
- (NSArray*) allSubscriptions;

/**
 When set, the object implementing the GSConnectionNotificationDelegate protocol will be notified of all
 connection state changes.
 
 @see GSConnectionNotificationDelegate
 */
@property (nonatomic, assign) id<GSConnectionNotificationDelegate> notificationDelegate;

/**
 Get/set the policy which defines connection behavior. 
 */
@property (nonatomic, assign) id<GSConnectionPolicyDelegate> policyDelegate;

/**
 @returns  an instance of the Message Waiting Indication service to be used for first party call control
 */
- (id<GSMessageWaitingIndicationService>) messageWaitingIndicationService;

/**
 Get/set the delegate responsible for notifications about Message Wainting Indication state.
 */
@property (nonatomic, assign) id<GSMessageWaitingIndicationNotificationDelegate> messageWaitingIndicationNotificationDelegate;

/**
 @returns  an instance of the Video service to be used for first party call control
 */
//vpolishc
#if !TARGET_OS_IPHONE
- (id<GSVideoService>) videoService;
#endif

/**
 Get/set the delegate responsible for notifications about Video Stream state.
 */
//vpolishc
#if !TARGET_OS_IPHONE
@property (nonatomic, assign) id<GSVideoStreamNotificationDelegate> videoStreamNotificationDelegate;
#endif

/**
 Get/set the policy which defines video stream behavior. 
 */
//vpolishc
#if !TARGET_OS_IPHONE
@property (nonatomic, assign) id<GSVideoStreamPolicyDelegate> videoStreamPolicyDelegate;
#endif



@end

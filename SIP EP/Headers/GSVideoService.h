//
//  GSVideoService.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSVideoStreamPolicyDelegate.h"
#import "GSVideoStreamNotificationDelegate.h"
#import "GSVideoStreamConfiguration.h"

@protocol GSVideoService <NSObject>

/**
 Starts a local video with configuration
 
 @param configuration.
 
 @returns the result of the operation.
 */
- (GSResult) startLocalVideoWithConfiguration:(GSVideoStreamConfiguration*) configuration;

/**
 Starts a remote video for the session with configuration
 
 @param session object.
 @param configuration.
 
 @returns the result of the operation.
 */
- (GSResult) startIncomingVideoForSession:(id<GSSession>) session withConfiguration:(GSVideoStreamConfiguration*) configuration;

/**
 Starts a outgoing video for the session with configuration
 
 @param session object.
 @param configuration.
 
 @returns the result of the operation.
 */
- (GSResult) startOutgoingVideoForSession:(id<GSSession>) session withConfiguration:(GSVideoStreamConfiguration*) configuration;

/**
 Stops a local video
 
 @returns the result of the operation.
 */
- (GSResult) stopLocalVideo;

/**
 Stops a remote video for the session
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) stopIncomingVideoForSession:(id<GSSession>) session;

/**
 Stops an outgoing video for the session
 
 @param session object.
 
 @returns the result of the operation.
 */
- (GSResult) stopOutgoingVideoForSession:(id<GSSession>) session;

/**
 Get/set the policy which defines video behavior.
 */
@property (nonatomic, assign) id<GSVideoStreamPolicyDelegate> policyDelegate;

/**
 Get/set the delegate responsible for notifications about video stream state.
 */
@property (nonatomic, assign) id<GSVideoStreamNotificationDelegate> notificationDelegate;
    
@end

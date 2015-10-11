//
//  GSSessionPolicyDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/13/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPolicyDelegate.h"
#import "GSSession.h"

/**
 Defines aspects of session manager's behavior
 
 @see GSSessionManager
 */
@protocol GSSessionPolicyDelegate <GSPolicyDelegate>
@required

/**
 * Implement to specify the list of codecs to be used when establishing a session
 *
 * @returns the prioritized codec list, sorted from highest to lowest priority or an empty collection to use the default priorities and all available
 codecs.
 */

- (NSArray*) prioritizedCodecList;

/**
 Implement to specify the DTMF method to be used for a given session
 
 @param session the session for which the DTMF method is being considered
 
 @returns the DTMF method as defined by the GSDtmfMethod enumeration
 
 @see GSDtmfMethod
 */
- (GSDtmfMethod) dtmfMethodForSession:(id<GSSession>) session;

/**
 Implement to specify whether the incoming session should be automatically answered.

 @param session the incoming session

 @returns YES to answer or NO to send 180 Ringing
 */
- (BOOL) shouldAnswerIncomingSession:(id<GSSession>) session;

/**
 Implement to specify whether the video codec is available or not.
 
 @param session the incoming session
 
 @returns YES if video codec is available or NO if video codec is not available
 */
- (BOOL) isVideoCodecAvailable;

/**
 Implement to specify whether the incoming session should be automatically answered with video.
 
 @param session the incoming session
 
 @returns YES to answer with video or NO to answer with audio
 */
- (BOOL) shouldAcceptVideo:(id<GSSession>) session;

/**
 Implement to specify whether the incoming session should be rejected when headset not available.
 
 @param session the incoming session
 
 @returns YES to reject session  or NO to do nothing
 */
- (BOOL) rejectWhenHeadsetNa:(id<GSSession>) session;

/**
 Implement to specify respond SIP code when headset not available.
 
 @param session the incoming session
 
 @returns SIP code string
 */
- (NSString*) sipCodeWhenHeadsetNa:(id<GSSession>) session;

/**
 Implement to specify AGC mode for all sessions.
  
 @returns 0 when AGC functionality is disabled
 @returns 1 when AGC functionality is enabled (default mode) 
 */
- (int) agcMode;

/**
 Implement to specify DTX mode for all sessions.
 
 @returns 0 when DTX functionality is disabled
 @returns 1 when DTX functionality is enabled (default mode)
 */

- (int) dtxMode;
/**
 Implement to specify VAD level for all sessions.
 
 @returns value from 0 to 3 where:
    0 is conventional VAD level
    3 is aggressive high VAD level
 */
- (int) vadLevel;

@end

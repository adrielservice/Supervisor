//
//  GSEndpointPolicyDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/12/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPolicyDelegate.h"

/**
 This delegate is used to define aspects of endpoint behavior
 */
@protocol GSEndpointPolicyDelegate <GSPolicyDelegate>

/**
 Implement to define the user-agent header sent with SIP messages.
 
 @returns the user agent header
 */
-(NSString*) userAgent;

/**
 Use to specify if the OS Version should be included in the User Agent Header of the SIP message. 
 Note that this property cannot be changed after the endpoint has been configured.
 
 @returns true if the property should be included in the header.
 @returns false (default value) if the property should not be included in the header.
 */
- (BOOL) includeOSVersionInUserAgentHeader;

/**
 Use to specify QOS for SIP messages. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the DSCP bits to set for SIP messages.
 */
- (int) signalingQos;

/**
 Use to specify QOS for audio RTP packets. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the DSCP bits to set for RTP packets.
 */
- (int) audioQos;

/**
 Use to specify QOS for video RTP packets. Note that this property cannot be changed after the endpoint has been configured.
 
 @returns the integer value representing the DSCP bits to set for RTP packets.
 */
- (int) videoQos;

/**
 Use to specify QOS for secure SIP messages. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the DSCP bits to set for SIP messages.
 */
- (int) secureSignalingQos;

/**
 Use to specify SIP port min for SIP messages. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the SIP port min.
 */
- (int) sipPortMin;

/**
 Use to specify SIP port max for SIP messages. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the SIP port max.
 */
- (int) sipPortMax;

/**
 Use to specify RTP port min for media stream. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the RTP port min.
 */
- (int) rtpPortMin;

/**
 Use to specify RTP port max for media stream. Note that this property cannot be changed after the endpoint has been configured. 
 
 @returns the integer value representing the  RTP port max.
 */
- (int) rtpPortMax;

/**
 Use to specify RTP inactivity timeout for media stream. Note that this property cannot be changed after the endpoint has been configured.
 
 @returns the integer value representing the  RTP inactivity timeout in seconds.
    The valid values:  	= 0  and > 150  no inactivity detection
                          1 - 149       inactivity timeout interval
 Meaning: session should be released if inactivity is detected during the specified interval
 */
- (int) rtpInactivityTimeout;

//
- (BOOL) vqReportPublish;

// (str) URI of collector
-(NSString*) vqReportCollector;

// (int) kbps
- (int) videoMaxBitrate;

// (int) msec
- (int) sipTransactionTimeout;

// (int) 1:wave,2:core,
- (int) webrtcAudioLayer;

@end

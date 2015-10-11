//
//  GSSession.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 8/12/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMedia.h"
#import "GSConnection.h"
#import "GSAudioStream.h"

/**
 This protocol represents a SIP session (i.e. call)
 */
@protocol GSSession <NSObject>

/**
 The connection ID
 */
@property (nonatomic, readonly) int callId;

/**
 Retrieves the current session state
 */
@property (nonatomic, readonly) GSSessionState state;

/**d
 Retrieves the current session id.
 */
@property (nonatomic, copy, readonly) NSString* sessionId;

/**
 Retrieves the connection via which this session was established.
 */
@property (nonatomic, retain, readonly) id<GSConnection> connection;

/**
 Use this method to determine whether the specified media type is supported by the current session.
 
 @param media The media type.
 
 @returns YES if the media type is supported by the session, NO otherwise.
 */
- (BOOL) supportsMedia:(GSMedia*) media;

/**
 Represents Remote Party address
 
 @returns a string with remote party address
 */
@property (nonatomic, copy, readonly) NSString* remoteParty;

/**
 Gives a control to change IN and OUT devices volume
 
 @returns GSAudioStream object with ability to:
    changeOutputVolumeBy:(int)increment;
    changeInputVolumeBy:(int)increment;
 */
@property (nonatomic, retain, readonly) id<GSAudioStream> audioStream;

/**
 Stands for indicate that the session offers video
 
 @returns GSFlagStateTrue when video is presented in a given session
 @returns GSFlagStateFalse when video is NOT presented in a given session
 @returns GSFlagStateUnknown if has video indication is not applicable for this state
 */
@property (nonatomic) GSFlagState hasVideo;

/**
 Represents the current speaker volume
 
 @returns a number from 0 to 100 that represents the currently used speaker volume
 */
@property (nonatomic, readonly) int speakerVolume;

/**
 Represents the current mic volume
 
 @returns a number from 0 to 100 that represents the currently used mic volume
 */
@property (nonatomic, readonly) int micVolume;

@end

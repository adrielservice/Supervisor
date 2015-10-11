//
//  GSAudioStream.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 10/19/11.
//  Copyright (c) 2011 Genesys Labs. All rights reserved.
//

#import "GSEnums.h"

@protocol GSAudioStream

/**
 Changes the output level of the current audio stream
 */
- (GSResult) changeOutputVolumeBy:(int)increment;

/**
 Changes the input level of the current audio stream
 
 The Session Mic Volume Control not supported
 @ return GSResultFailed if the method is called
 */
- (GSResult) changeInputVolumeBy:(int)increment;

/**
 Get the input level of the current audio stream
 */
- (int) getInputVolume;

/**
 Get the output level of the current audio stream

 The Session Mic Volume Control not supported
 @ return 0 if the method is called
 */
- (int) getOutputVolume;

@end

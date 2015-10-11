//
//  GSAudioDevice.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDevice.h"

/**
 Defines functionality specific to an audio device. Note that if a given device supports media of type "audio," this device
 will implement GSAudioDevice protocol.
 */
@protocol GSAudioDevice <GSDevice>

/**
 Get the current route for the microphone
 */
@property (nonatomic,readonly) GSDeviceRoute micRoute;

/**
 Get the current route for the speaker
 */
@property (nonatomic,readonly) GSDeviceRoute speakerRoute;

/**
 Specifies where the mic signal is coming from.
 
 @param route the route the signal should take
 
 @return the result of the operation
 */
- (GSResult) routeMicSignalFrom:(GSDeviceRoute)route;

/**
 Specifies where the audio signal should be played.
 
 @param route the route the signal should take
 
 @return the result of the operation
 */
- (GSResult) routeSpeakerSignalTo:(GSDeviceRoute)route;

/**
 Used to determine if the device supports the specified audio capability for the microphone
 
 @param capability the requested capability
 
 @return YES if the capability is supported, NO otherwise.
 */
- (BOOL) supportsCapabilityForInput:(GSAudioDeviceCapability) capability;

/**
 Used to determine if the device supports the specified audio capability for the speaker
 
 @param capability the requested capability
 
 @return YES if the capability is supported, NO otherwise.
 */
- (BOOL) supportsCapabilityForOutput:(GSAudioDeviceCapability) capability;

/**
 Used to get speaker volume.
 
 @return a number between 0 and 100 representing the current speaker volume.
 */
@property (nonatomic, readonly) int speakerVolume;

/**
 Used to get speaker volume.
 
 @return a number between 0 and 100 representing the current mic volume.
 */
@property (nonatomic, readonly) int micVolume;

/**
 Changes the speaker volume to the specified value.
 
 @param value a number between 0 and 100 representing the current speaker volume.
 
 @returns the result of the operation
 */
- (GSResult) changeSpeakerVolumeTo:(int) value;

/**
 Changes the mic volume to the specified value.
 
 @param value a number between 0 and 100 representing the current mic volume.
 
 @returns the result of the operation
 */
- (GSResult) changeMicVolumeTo:(int) value;

@end

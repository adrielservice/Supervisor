//
//  GSVideoDevice.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 1/30/14.
//  Copyright (c) 2014 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMedia.h"

/**
 Defines functionality specific to an audio device. Note that if a given device supports media of type "audio," this device
 will implement GSAudioDevice protocol.
 */
@protocol GSVideoDevice

/**
 Specifies the video device property:
 videoDeviceName          represents system device name
 */
@property (nonatomic, copy) NSString* videoDeviceName;

/**
 Specifies the video device property:
 videoDeviceDriverName    represents system device driver name
 */
@property (nonatomic, copy) NSString* videoDeviceDriverName;

/**
 Specifies the video device property:
 videoDeviceId            represents system device ID
 */
@property (nonatomic) int videoDeviceId;

/**
 Determines whether the device supports the specified media type.
 
 @param media the media type
 
 @returns YES if the media type is supported, otherwise NO.
 */
- (BOOL) supportsMedia:(GSMedia*) media;

/**
 Used to determine the video device capability:
 videoDeviceCapabilityWidth     represent
 
 @param capability the requested capability
 
 @return YES if the capability is supported, NO otherwise.
 */

@property (nonatomic, copy) NSArray* videoDeviceCapabilityWidth;

@property (nonatomic, copy) NSArray* videoDeviceCapabilityHeight;

@property (nonatomic, copy) NSArray* videoDeviceCapabilityFps;

@property (nonatomic, copy) NSArray* videoDeviceCapabilityRaw;

/**
 
 Used to determine if the device supports the specified audio capability for the speaker
 
 @param capability the requested capability
 
 @return YES if the capability is supported, NO otherwise.
 */
//- (BOOL) supportsCapabilityForOutput:(GSAudioDeviceCapability) capability;

/**
 Used to get speaker volume.
 
 @return a number between 0 and 100 representing the current speaker volume.
 */
//@property (nonatomic, readonly) int speakerVolume;

/**
 Used to get speaker volume.
 
 @return a number between 0 and 100 representing the current mic volume.
 */
//@property (nonatomic, readonly) int micVolume;

/**
 Changes the speaker volume to the specified value.
 
 @param value a number between 0 and 100 representing the current speaker volume.
 
 @returns the result of the operation
 */
//- (GSResult) changeSpeakerVolumeTo:(int) value;

/**
 Changes the mic volume to the specified value.
 
 @param value a number between 0 and 100 representing the current mic volume.
 
 @returns the result of the operation
 */
//- (GSResult) changeMicVolumeTo:(int) value;

@end

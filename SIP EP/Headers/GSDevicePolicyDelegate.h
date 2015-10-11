//
//  GSDevicePolicyDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/27/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPolicyDelegate.h"
#import "GSDevice.h"

/**
 This delegate is used to define aspects of the device manager's behavior.
 */
@protocol GSDevicePolicyDelegate <GSPolicyDelegate>

/**
 Implement to define the device that should be used for input. This method will be called on startup as well as when
 a device has been connected or disconnected.
 
 @param deviceList the list of current system input devices
 @param media the media type for which the selected device will be used
 
 @returns the device to use for input
 */
- (id<GSDevice>) chooseActiveInputDeviceFromList:(NSArray*) deviceList forMedia:(GSMedia*) media;

/**
 Implement to define the device that should be used for output. This method will be called on startup as well as when
 a device has been connected or disconnected.
 
 @param deviceList the list of current system output devices
 @param media the media type for which the selected device will be used

 @returns the device to use for output
*/
- (id<GSDevice>) chooseActiveOutputDeviceFromList:(NSArray*) deviceList forMedia: (GSMedia*) media;

/**
 Implement to define the audio device that should be used for session.
 
 @returns YES to use headset the device to use for output
 */
- (BOOL) useHeadset;

/**
 Implement to define the audio device that should be used for session.
 
 @returns GSFlagStateTrue if headset device is available to use
 @returns GSFlagStateFalse if headset device is Not available to use
 @returns GSFlagStateUnknown if headset device availability is not applicable in the configuration
 */
- (GSFlagState) headsetAvailable;

@end

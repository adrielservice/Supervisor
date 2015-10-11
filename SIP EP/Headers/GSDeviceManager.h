//
//  GSDeviceManager.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 8/17/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDevice.h"
#import "GSMedia.h"
#import "GSDeviceNotificationDelegate.h"
#import "GSDevicePolicyDelegate.h"

@protocol GSDeviceManager <NSObject>

/**
 Retrieve the input device (e.g. microphone) that is currently used for the specified media type.
 
 @param media the media type for which to retrieve the input device
 
 @returns the currently active input device
 */
- (id<GSDevice>) activeInputDeviceForMedia:(GSMedia*) media;

/**
 Retrieve the output device (e.g. speaker) that is currently used for the specified media type.
 
 @param media the media type for which to retrieve the output device
 
 @returns the currently active output device
 */
- (id<GSDevice>) activeOutputDeviceForMedia:(GSMedia*) media;

/**
 This method should be called to set the input device for the specified media.
 
 @param device the device to be used as the input device (e.g. microphone)
 @param media the media type for which this input device  will be used (e.g. audio)
 */
- (GSResult) useInputDevice:(id<GSDevice>) device forMedia:(GSMedia*) media;

/**
 This method should be called to set the output device for the specified media.
 
 @param device the device to be used as the output device (e.g. speaker)
 @param media the media type for which this output device will be used (e.g. audio)
 */
- (GSResult) useOutputDevice:(id<GSDevice>) device forMedia:(GSMedia*) media;

/**
 Returns the list of all input/output devices configured in the system. 
 
 @return an array of devices.
 */
- (NSArray*) systemDevices;

/**
 Returns the list of all input/output devices that support the specified media type.

 @param media specifies the media type that the returned devices should support 
 @return an array of devices.
 */
- (NSArray*) systemDevicesForMedia:(GSMedia*) media;

/**
 Returns a list of devices which match the specified filters.
 
 @param media if specified, allows the user to retrieve devices that support the specified media type
 @param forInput if YES, input devices will be included, if NO, input devices will not be included
 @param forOutput if YES, output devices will be included, if NO, output devices will not be included
 
 @returns an array of devices.
 */
- (NSArray*) systemDevicesForMedia:(GSMedia*) media forInput:(BOOL) forInput forOutput:(BOOL) forOutput;

/**
 Returns a list of video devices.
 
 @param media if specified, allows the user to retrieve devices that support the specified media type
 
 @returns an array of devices.
 */
//- (NSArray*) systemDevicesForMedia:(GSMedia*) media;

- (NSArray*) systemVideoDevicesForMedia:(GSMedia*) media;

/**
 Get/set the delegate that will be used to recieve notifications about device state
 */
@property (nonatomic, assign) id<GSDeviceNotificationDelegate> notificationDelegate;

/**
 Get/set the delegate that will be used to specify the device manager's behavior.
 */
@property (nonatomic, assign) id<GSDevicePolicyDelegate> policyDelegate;

/**
 Get the headset available to support auto answer behavior.
 
 @returns GSFlagStateTrue if headset device is available to use
 @returns GSFlagStateFalse if headset device is Not available to use
 @returns GSFlagStateUnknown if headset device availability is not applicable in the configuration
 */
@property (nonatomic) GSFlagState headsetAvailable;

/**
 Get the headset In device available to support auto answer behavior.

 @returns True if headset IN device is available to use
 @returns False if headset IN device is Not available to use
 */
@property (nonatomic) BOOL headsetInAvailable;

/**
 Get the headset Out device available to support auto answer behavior.
 
 @returns True if headset OUT device is available to use
 @returns False if headset OUT device is Not available to use
 */
@property (nonatomic) BOOL headsetOutAvailable;

@end

//
//  GSDeviceNotificationDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDevice.h"

/**
 Used to receive notifications about device state changes.
 */
@protocol GSDeviceNotificationDelegate <NSObject>
@optional

/**
 Implement to be notified when a new I/O device has been connected to the system.
 
 @param device the newly connected device
 @param media the media type supported by this device
 */
-(void) deviceWasConnected:(id<GSDevice>) device forMedia:(GSMedia*) media; 

/**
 Implement to be notified when a new I/O device has been connected to the system.
 
 @param device the newly disconnected device
 @param media the media type supported by this device
 */
-(void) deviceWasDisconnected:(id<GSDevice>) device forMedia:(GSMedia*) media;

/**
 Implement to be notified when the active input device for the passed media type has been changed.

 @param media the media type for which the input device was used.
 */
-(void) activeInputDeviceDidChangeForMedia:(GSMedia*) media;

/**
 Implement to be notified when the active output device for the passed media type has been changed.
 
 @param media the media type for which the output device was used.
 */
-(void) activeOutputDeviceDidChangeForMedia:(GSMedia*) media;

@end

//
//  GSDevice.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 8/22/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GSMedia.h"

/**
 Represents a system input or output device that can be used for a media sesssion
 */
@protocol GSDevice <NSObject>

/**
 The name of the device.
 */
@property (nonatomic, copy, readonly) NSString* name;

/**
 The name of the driver for this device.
 */
@property (nonatomic, copy, readonly) NSString* driverName;

/**
 Specifies whether the device can be used for input operations
 */
@property (nonatomic, readonly) BOOL canInput;

/**
 Specifies whether the device can be used for output operations
 */
@property (nonatomic, readonly) BOOL canOutput;

/**
 Specifies whether the device has volume control operations
 */
@property (nonatomic) BOOL hasVolumeControl;

/**
 Determines whether the device supports the specified media type.
 
 @param media the media type 
 
 @returns YES if the media type is supported, otherwise NO.
 */
- (BOOL) supportsMedia:(GSMedia*) media;

@end

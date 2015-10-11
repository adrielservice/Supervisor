//
//  GSMedia.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSEnums.h"

/**
 Defines a media type
 */
@interface GSMedia : NSObject {
@private
    NSString* name;
    GSMediaType type;
}

/**
 The name of the media type represented as a string
 */
@property (nonatomic, copy) NSString* name;

/**
 The name of the media type represented as an enumeration value
 */
@property (nonatomic) GSMediaType type;

/**
 Defines the audio media type.
 */
+(GSMedia*) audioMedia;

/**
 Defines the video media type.
 */
+(GSMedia*) videoMedia;

@end

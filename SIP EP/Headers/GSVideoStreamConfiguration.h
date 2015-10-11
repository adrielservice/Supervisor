//
//  GSVideoStreamConfiguration.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 3/6/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSVideoStreamNotificationDelegate.h"
#import "GSVideoStreamPolicyDelegate.h"

@interface GSVideoStreamConfiguration : NSObject {
@private
    //vpolishc
#if !TARGET_OS_IPHONE
    NSWindow* window;
#endif
    void* renderer;
    unsigned int zOrder;
    float left;
    float top;
    float right;
    float bottom;    
}

/** 
For outgoing video this is the preview window. For incoming, it's the incoming video window. If null, video display will not
be handled by the framework. Application should register for the incomingFrameReceived or outgoingFrameReadyToSend events 
to receive the frame data and process the frame in whatever manner necessary.
*/
//vpolishc
#if !TARGET_OS_IPHONE
@property (nonatomic, retain) NSWindow* window;
#endif


@property (nonatomic) void* renderer;
@property (nonatomic) unsigned int zOrder;
@property (nonatomic) float left;
@property (nonatomic) float top;
@property (nonatomic) float right;
@property (nonatomic) float bottom;

//vpolishc
#if !TARGET_OS_IPHONE
- (id)initWithWindow:(NSWindow*) theWindow
            renderer:(void*) theRenderer
              zOrder:(unsigned int) theZorder
                left:(float) theLeft
                 top:(float) theTop
               right:(float) theRight
              bottom:(float) theBottom;
#endif
@end

//
//  GSVideoStreamNotificationDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 3/6/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSSession.h"

@protocol GSVideoStreamNotificationDelegate <NSObject>
@optional

- (void) incomingVideoStreamOpenedForSession:(id<GSSession>) session;
- (void) outgoingVideoStreamOpenedForSession:(id<GSSession>) session;

- (void) incomingVideoStreamClosedForSession:(id<GSSession>) session;
- (void) outgoingVideoStreamClosedForSession:(id<GSSession>) session;

- (void) incomingFrameReceived:(NSData*) frame forSession:(id<GSSession>) session;
- (void) outgoingFrameReadyToSend:(NSData*) frame forSession:(id<GSSession>) session;
@end

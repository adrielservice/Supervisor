//
//  GSEndpointNotificationDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This delegate is used to receive notifications about endpoint state changes.
 */
@protocol GSEndpointNotificationDelegate <NSObject>

@required

/**
 Called when the sip endpoint status has been changed.
 
 @see GSEndpointEvent
 */
- (void) endpointStateDidChange;

@end

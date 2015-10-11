//
//  GSSessionNotificationDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 6/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSSession.h"

/**
 Used to receive session state change notifications
 */
@protocol GSSessionNotificationDelegate <NSObject>
@required
   
/**
 Called when the state of a session has been changed
 
 @param session the session which has had a state change
 */
- (void) sessionStateDidChange:(id<GSSession>) session;

@end

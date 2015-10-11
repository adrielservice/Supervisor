//
//  GSPolicyDelegate.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/14/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The parent class for all policy delegates. 
 */
@protocol GSPolicyDelegate <NSObject>
@optional

/**
 This method can be called to configure the policy.
 
 @param theConfiguration a dictionary containing configuration information for the specified policy object
 */
- (void) configureWithDictionary:(NSDictionary*) theConfiguration;
@end

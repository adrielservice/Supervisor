//
//  GSDefaultDevicePolicy.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/27/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDevicePolicyDelegate.h"

/**
 Defines the default device policy. To configure the device policy either pass it the configuration dictionary via the "configureWithDictionary" 
 method of the parent GSPolicyDelegate protocol or pass the configuration dictionary under the key "GSDefaultEndpointPolicy" to 
 the configureWithDictionary method of GSEndpoint. The valid configuration key/value pairs are as follows:
*/

@interface GSDefaultDevicePolicy : NSObject <GSDevicePolicyDelegate> {
@private
    NSDictionary* configuration;
}

@property (nonatomic, retain, readonly) NSDictionary* configuration;

@end

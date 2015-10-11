//
//  GSDefaultEndpointPolicy.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/26/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSEndpointPolicyDelegate.h"

/**
 Defines the default endpoint policy. To configure the endpoint policy either pass it the configuration 
 dictionary via the "configureWithDictionary" method of the parent  GSPolicyDelegate protocol or pass the
 configuration dictionary under the key "GSDefaultEndpointPolicy" to the configureWithDictionary method of 
 GSEndpoint. The valid configuration key/value pairs are as follows:
 
 includeOSVersionInUserAgentHeader:YES/NO (BOOL) -- If set to YES, the user agent field will include the OS version the client is currently running on. 
 If not specified, this option is assumed to be "NO." 
 
 networkInterfaceName: The name of the network interface from which to retrieve the IP address to be used when generating contact headers. 
 If not specified, an internal selection algorithm will be used.
 */
@interface GSDefaultEndpointPolicy : NSObject <GSEndpointPolicyDelegate> {
@private
    NSDictionary* configuration;
}

/**
 Endpoint configuration
 
 @returns a dictionary instance with endpoint configuration 
 */
@property (nonatomic, retain, readonly) NSDictionary* configuration;
@end

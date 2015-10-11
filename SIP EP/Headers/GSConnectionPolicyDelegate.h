//
//  GSConnectionPolicy.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 12/20/11.
//  Copyright (c) 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPolicyDelegate.h"

/**
 This policy delegate is used to define connection behavior
 */
@protocol GSConnectionPolicyDelegate <GSPolicyDelegate>

/**
 Used to specify the host name or IP address at which all managed connections can be reached.
 
 @returns an IP address, a publicly visible host name, or nil to use an internal selection algorithm
 */
- (NSString*) publicAddress;

/**
 Used to specify the IP Versions.
 
 IPv4 - select local IPv4 address (ignore IPv6)
 IPv6 - select local IPv6 address (ignore IPv4)
 IPv4,IPv6 or empty - select IPv4 if exists, otherwise IPv6 (this is default)
 IPv6,IPv4 - select IPv6 if exists, otherwise IPv4
 
 NOTE: this option takes no effect if public-address option specifies explicit IP address.
 @returns an IP Version to be used to identify the host IP Address
 */
- (NSString*) ipVersions;

@end

//
//  GSDefaultSessionPolicy.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 9/13/11.
//  Copyright 2011 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSSessionPolicyDelegate.h"

/**
 Defines the default session policy as follows:
 
 Codecs: Any of the supported codecs can be used for an audio session in the following order of priority:
 
 1. speex/16000/1
 2. speex/8000/1
 3. speex/32000/1
 4. iLBC/8000/1
 5. GSM/8000/1
 6. PCMU/8000/1
 7. PCMA/8000/1
 
 DTMF: Will always return Rfc2833
 
 Auto answer: Will return "NO" for all sessions. 
 
 This default behavior can be modified by calling the "configureWithDictionary" method defined in the GSPolicyDelegate protocol. The dictionary format
 for the session policy is specified below. Note that the prefered method of configuring this policy is by creating a "GSDefaultSessionPolicy" 
 key in the GSEndpoint's configuration dictionary with the value being the session policy's configuration dictionary. 
 
 The possible key/value pairs in the configuration dictionary are as follows:
 
 [key:value(type)]
 
 auto_answer:YES if all calls should be answered automatically, NO otherwise (BOOL)
 
 dtmf_method: One of: Rfc2833, Info, InbandRtp (NSString)
 
 codecs:(NSDictionary)
 speex/16000/1:<priority value> Higher priority means the codec has preference in codec negotiation (NSNumber)
 speex/8000/1:(NSNumber)
 speex/32000/1:(NSNumber)
 iLBC/8000/1:(NSNumber)
 GSM/8000/1:(NSNumber)
 PCMU/8000/1:(NSNumber)
 PCMA/8000/1:(NSNumber)
 */
@interface GSDefaultSessionPolicy : NSObject <GSSessionPolicyDelegate> {
@private
    NSDictionary* configuration;
}

@property (nonatomic, retain, readonly) NSDictionary* configuration;

@end

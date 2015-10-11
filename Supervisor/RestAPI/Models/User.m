//
//  User.m
//  VoiceFit
//
//  Created by David Beilis on 4/27/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import "User.h" 
#import <RKObjectMapping.h>

@implementation User

+(RKObjectMapping*)defineRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"username":   @"username",
                                                  @"phoneNumber":   @"phoneNumber",
                                                  }];
    
    return mapping;
};

@end

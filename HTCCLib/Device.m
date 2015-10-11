//
//  Device.m
//  HTCCLib
//
//  Created by Arkady on 3/11/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "Device.h"

@implementation Device

+ (instancetype)createFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        Device *device = [[self alloc] init];
        [device updateFromDict:dict];
        return device;
    }
    else
        return nil;
}

- (void)updateFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        if ([dict[@"id"] isKindOfClass:[NSString class]])
            _deviceID = dict[@"id"];
        if ([dict[@"phoneNumber"] isKindOfClass:[NSString class]])
            _phoneNumber = dict[@"phoneNumber"];
        _doNotDisturb = ([dict[@"doNotDisturb"] isKindOfClass:[NSString class]] && [dict[@"doNotDisturb"] isEqualToString:@"On"]) ? YES: NO;

        if ([dict[@"userState"] isKindOfClass:[NSDictionary class]]) {
            _userState = dict[@"userState"];
        }
    }
}

@end

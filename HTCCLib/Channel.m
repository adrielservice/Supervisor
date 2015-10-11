//
//  Channel.m
//  HTCCLib
//
//  Created by Arkady on 3/11/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "Channel.h"

@implementation Channel

+ (instancetype)createFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        Channel *channel = [[self alloc] init];
        [channel updateFromDict:dict];
        return channel;
    }
    else
        return nil;
}

- (void)updateFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        if ([dict[@"channel"] isKindOfClass:[NSString class]])
            _channelName = dict[@"channel"];
         _doNotDisturb = ([dict[@"dndState"] isKindOfClass:[NSString class]] && [dict[@"dndState"] isEqualToString:@"On"]) ? YES: NO;
        
        if ([dict[@"userState"] isKindOfClass:[NSDictionary class]]) {
            _userState = dict[@"userState"];
        }
    }
}


@end

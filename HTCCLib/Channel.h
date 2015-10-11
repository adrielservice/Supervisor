//
//  Channel.h
//  HTCCLib
//
//  Created by Arkady on 3/11/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (strong, nonatomic, readonly) NSString *channelName;
@property (nonatomic, readonly) BOOL doNotDisturb;
@property (strong, nonatomic, readonly) NSDictionary *userState;

+ (instancetype)createFromDict:(NSDictionary *)dict;

- (void)updateFromDict:(NSDictionary *)dict;

@end

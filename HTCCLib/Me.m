//
//  Me.m
//  HTCC Sample
//
//  Created by Arkady on 10/24/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "Me.h"
#import "ConnectionController.h"
#import "Device.h"
#import "Channel.h"
#import "NSArray+HTCC.h"

@interface Me ()

@property (strong, nonatomic, readwrite) NSMutableArray *devices;
@property (strong, nonatomic, readwrite) NSMutableArray *channels;
@property (strong, nonatomic, readwrite) NSMutableArray *calls;
@property (strong, nonatomic, readwrite) NSMutableDictionary *consultCallURIs; //key - Consult Call URI, value - Parent Call URI
@property (strong, nonatomic, readwrite) NSMutableArray *chats;
@property (strong, nonatomic, readwrite) NSMutableArray *emails;

@end

@implementation Me

+ (instancetype)initMe {
    static dispatch_once_t once;
    static Me *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        if (sharedInstance.calls == nil)
            sharedInstance.calls = [NSMutableArray arrayWithCapacity:1];
        if (sharedInstance.consultCallURIs == nil)
            sharedInstance.consultCallURIs = [NSMutableDictionary dictionaryWithCapacity:1];
        if (sharedInstance.chats == nil)
            sharedInstance.chats = [NSMutableArray arrayWithCapacity:1];
        if (sharedInstance.emails == nil)
            sharedInstance.emails = [NSMutableArray arrayWithCapacity:1];
        if (sharedInstance.devices == nil)
            sharedInstance.devices = [NSMutableArray arrayWithCapacity:1];
        if (sharedInstance.channels == nil)
            sharedInstance.channels = [NSMutableArray arrayWithCapacity:1];
    });
    return sharedInstance;
}

- (void)updateDevices:(NSArray *)newDevices {
    // According to Apple documentation:
    //
    // A notification center delivers notifications to observers synchronously.
    // In other words, when posting a notification, control does not return to the poster
    // until all observers have received and processed the notification.
    if ([newDevices isKindOfClass:[NSArray class]] && [newDevices areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
        [newDevices enumerateObjectsUsingBlock:^(id dict, NSUInteger idx, BOOL *stop) {
            NSUInteger index = [_devices indexOfObjectPassingTest:^BOOL(id device, NSUInteger idx, BOOL *stop) {
                return ([((Device *)device).deviceID isEqualToString:dict[@"id"]]);
            }];
            if (index == NSNotFound)
                [_devices addObject:[Device createFromDict:dict]];
            else
                [_devices[index] updateFromDict:dict];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDevicesChannelsNotification object:self];
    }
}

- (void)updateChannels:(NSArray *)newChannels {
    if ([newChannels isKindOfClass:[NSArray class]] && [newChannels areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
        [newChannels enumerateObjectsUsingBlock:^(id dict, NSUInteger idx, BOOL *stop) {
            NSUInteger index = [_channels indexOfObjectPassingTest:^BOOL(id channel, NSUInteger idx, BOOL *stop) {
                return ([((Channel *)channel).channelName isEqualToString:dict[@"channel"]]);
            }];
            if (index == NSNotFound)
                [_channels addObject:[Channel createFromDict:dict]];
            else
                [_channels[index] updateFromDict:dict];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDevicesChannelsNotification object:self];
    }
}

- (void)updateInteraction:(NSMutableArray *)interArray
           newInteraction:(NSDictionary *)newInteraction
             notification:(NSString *)notificationName {
    [self updateInteraction:interArray newInteraction:newInteraction notification:notificationName userInfo:nil];
}

- (void)updateInteraction:(NSMutableArray *)interArray
           newInteraction:(NSDictionary *)newInteraction
             notification:(NSString *)notificationName
                 userInfo:(NSDictionary *)userInfo {
    NSParameterAssert(interArray != nil);
    if ([newInteraction isKindOfClass:[NSDictionary class]]) {
        
        NSUInteger index = [interArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString *newID = ([newInteraction[@"id"] length]) ? newInteraction[@"id"] : [[newInteraction[@"uri"] pathComponents] lastObject];
            return ([((Interaction *)obj).ixnID isEqualToString:newID]);
        }];
        
        if (index == NSNotFound) {
            Interaction *ixn = [Interaction createFromDict:newInteraction];
            NSLog(@"Adding interaction ixnID: %@, at index: %tu, to: %p", ixn.ixnID, interArray.count, interArray);
            [interArray addObject:ixn];
        }
        else
            [interArray[index] updateFromDict:newInteraction];
        
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        userDict[@"index"] = @(index);
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userDict];
    }
}

#pragma mark - Make Strings Functions

- (NSString *)makeToastString:(Interaction *)ixn
{
    __block NSString *str = @"";
    if (ixn.userData) {
        [_toastData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]] &&
                [obj[@"name"] isKindOfClass:[NSString class]] &&
                [ixn.userData[obj[@"name"]] length]) {
                NSString *newAttr = [NSString stringWithFormat:@"%@: %@", obj[@"displayName"], ixn.userData[obj[@"name"]]];
                str = [str stringByAppendingFormat:@"%@\n", newAttr];
            }
        }];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    return str;
}

- (NSArray *)makeCaseData:(Interaction *)ixn {
    //Make an array of attached data keys that have non-empty values
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    if (ixn.userData) {
        [_caseData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]] &&
                [obj[@"name"] isKindOfClass:[NSString class]] &&
                [ixn.userData[obj[@"name"]] length]) {
                [arr addObject:obj];
            }
        }];
    }
    return  arr;
}

@end

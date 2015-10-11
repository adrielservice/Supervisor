//
//  Target.m
//  HTCC Sample
//
//  Created by Arkady on 11/9/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "Contact.h"

@implementation Contact

+ (instancetype)createContact:(NSDictionary *)src
{
    if (![src isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    Contact *target = [[self alloc] init];
    
    if ([src[@"id"] isKindOfClass:[NSString class]]) {
        target.hID = src[@"id"];
    }
    if ([src[@"type"] isKindOfClass:[NSString class]]) {
        target.targetType = src[@"type"];
        if ([src[@"type"] isEqualToString:@"User"]) {
            //Contact
            target.name = @"";
            if ([src[@"firstName"] isKindOfClass:[NSString class]]) {
                target.name = src[@"firstName"];
            }
            if (src[@"firstName"] && [src[@"lastName"] isKindOfClass:[NSString class]]) {
                target.name = [target.name stringByAppendingString:@" "];
            }
            if ([src[@"lastName"] isKindOfClass:[NSString class]]) {
                target.name = [target.name stringByAppendingString:src[@"lastName"]];
            }
        }
        else {
            //Queue or Custom
            if ([src[@"name"] isKindOfClass:[NSString class]]) {
                target.name = src[@"name"];
            }
        }
    }
    
    if ([src[@"phoneNumbers"] isKindOfClass:[NSArray class]] && [src[@"phoneNumbers"] count] && [src[@"phoneNumbers"][0] isKindOfClass:[NSDictionary class]]) {
        target.phoneNumber = src[@"phoneNumbers"][0][@"phoneNumber"];
    }
        
    if ([src[@"availability"] isKindOfClass:[NSDictionary class]]) {
        //Build presense dictionary in format: @{"chat" : false, "email" : true}
        NSArray *av = src[@"availability"][@"channels"];
        if (av && [av isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *cd = [[NSMutableDictionary alloc] init];
            for (NSDictionary *d in av) {
                if ([d isKindOfClass:[NSDictionary class]] &&
                    [d[@"channel"] isKindOfClass:[NSString class]]) {
                    [cd setValue:d[@"available"] forKey:d[@"channel"]];
                }
            }
            if (cd.count) {
                target.presence = cd;
            }
        }
    }
    return target;
}


//To support containsObject in Contacts collection
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Contact self]]) {
        Contact *other = object;
        return [_hID isEqualToString:other->_hID] &&
        [_name isEqualToString:other->_name] &&
        [_phoneNumber isEqualToString:other->_phoneNumber] &&
        [_presence isEqualToDictionary:other->_presence] &&
        [_targetType isEqualToString:other->_targetType];
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    // Equal objects must hash the same.
    return [_hID hash] + [_name hash] + [_phoneNumber hash] + [_presence hash] + [_targetType hash];
}

@end

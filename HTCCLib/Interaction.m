//
//  Interaction.m
//  HTCC Sample
//
//  Created by Arkady on 1/14/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "Interaction.h"
#import "NSArray+HTCC.h"

@implementation Interaction

+ (instancetype)createFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        Interaction *ixn = [[self alloc] init];
        [ixn updateFromDict:dict];
        return ixn;
    }
    else
        return nil;
}

- (void)updateFromDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        if ([dict[@"id"] isKindOfClass:[NSString class]])
            _ixnID = dict[@"id"];
        if ([dict[@"uri"] isKindOfClass:[NSString class]]) {
            _uri = dict[@"uri"];
            if (_ixnID.length == 0 && ![[[_uri pathComponents] lastObject] isEqualToString:@"null"]) {
                _ixnID = [[_uri pathComponents] lastObject];
            }
        }
        if ([dict[@"state"] isKindOfClass:[NSString class]])
            _state = dict[@"state"];
        if ([dict[@"participants"] isKindOfClass:[NSArray class]] && [dict[@"participants"] areAllArrayElementsMembersOfClass:[NSDictionary class]])
            _participants = dict[@"participants"];
        if ([dict[@"capabilities"] isKindOfClass:[NSArray class]] && [dict[@"capabilities"] areAllArrayElementsMembersOfClass:[NSString class]])
            _capabilities = dict[@"capabilities"];
        if ([dict[@"userData"] isKindOfClass:[NSDictionary class]]) {
            _userData = dict[@"userData"];
        }
        
        if ([dict[@"callType"] isKindOfClass:[NSString class]])
            _callType = dict[@"callType"];
        if ([dict[@"callUuid"] isKindOfClass:[NSString class]])
            _callUuid = dict[@"callUuid"];
        if ([dict[@"parentCallUri"] isKindOfClass:[NSString class]])
            _parentCallUri = dict[@"parentCallUri"];
        if ([dict[@"deviceUri"] isKindOfClass:[NSString class]])
            _deviceUri = dict[@"deviceUri"];
        
        if ([dict[@"messages"] isKindOfClass:[NSArray class]] && [dict[@"messages"] areAllArrayElementsMembersOfClass:[NSDictionary class]])
            _messages = dict[@"messages"];

        if ([dict[@"from"] isKindOfClass:[NSString class]])
            _emailFrom = dict[@"from"];
        if ([dict[@"to"] isKindOfClass:[NSArray class]] && [dict[@"to"] areAllArrayElementsMembersOfClass:[NSString class]])
            _emailTo = dict[@"to"];
        if ([dict[@"cc"] isKindOfClass:[NSArray class]] && [dict[@"cc"] areAllArrayElementsMembersOfClass:[NSString class]])
            _emailCc = dict[@"cc"];
        if ([dict[@"subject"] isKindOfClass:[NSString class]])
            _emailSubject = dict[@"subject"];
        if ([dict[@"bodyAsPlainText"] isKindOfClass:[NSString class]])
            _emailBody = dict[@"bodyAsPlainText"];
        if ([dict[@"parentId"] isKindOfClass:[NSString class]])
            _emailParentID = dict[@"parentId"];
        if ([dict[@"receivedDate"] isKindOfClass:[NSString class]])
            _emailReceivedDate = dict[@"receivedDate"];
    }
}

@end

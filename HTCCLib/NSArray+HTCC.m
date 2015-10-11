//
//  NSArray+HTCC.m
//  HTCCLib
//
//  Created by Arkady on 3/4/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "NSArray+HTCC.h"

@implementation NSArray (HTCC)


- (BOOL)areAllArrayElementsMembersOfClass:(Class)className {
    
    __block BOOL allStrings = TRUE;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:className]) {
            allStrings = FALSE;
            *stop = TRUE;
        }
    }];
    return allStrings;
}

@end

//
//  Target.h
//  HTCC Sample
//
//  Created by Arkady on 11/9/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (strong, nonatomic) NSString *hID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSDictionary *presence;
@property (strong, nonatomic) NSString *targetType;

+ (instancetype)createContact:(NSDictionary *)src;

@end

//
//  UserSession.h
//  Supervisor
//
//  Created by David Beilis on 4/27/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSession : NSObject

@property (nonatomic, retain) NSString            *user;
@property (nonatomic, retain) NSString            *userId;
@property (nonatomic, retain) NSString            *phoneNumber;

@end

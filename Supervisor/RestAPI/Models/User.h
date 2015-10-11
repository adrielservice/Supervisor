//
//  User.h
//  VoiceFit
//
//  Created by David Beilis on 4/27/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RKObjectMapping.h>


@interface User : NSObject

@property (nonatomic, copy) NSString  *firstName;
@property (nonatomic, copy) NSString  *lastName;
@property (nonatomic, copy) NSString  *username;
@property (nonatomic, copy) NSString  *phoneNumber;

+(RKObjectMapping*)defineRequestMapping;

@end

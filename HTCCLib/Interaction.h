//
//  Interaction.h
//  HTCC Sample
//
//  Created by Arkady on 1/14/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interaction : NSObject

//Common
@property (strong, nonatomic, readonly) NSString *ixnID;
@property (strong, nonatomic, readonly) NSString *state;
@property (strong, nonatomic, readonly) NSString *uri;
@property (strong, nonatomic, readonly) NSArray *participants;
@property (strong, nonatomic, readonly) NSArray *capabilities;
@property (strong, nonatomic, readonly) NSDictionary *userData;

//Voice
@property (strong, nonatomic, readonly) NSString *callType;
@property (strong, nonatomic, readonly) NSString *callUuid;
@property (strong, nonatomic, readonly) NSString *deviceUri;
@property (strong, nonatomic, readonly) NSString *parentCallUri;

//Chat
@property (strong, nonatomic, readonly) NSArray *messages;

//Email
@property (strong, nonatomic, readonly) NSString *emailFrom;
@property (strong, nonatomic, readonly) NSArray *emailTo;
@property (strong, nonatomic, readonly) NSArray *emailCc;
@property (strong, nonatomic, readonly) NSString *emailSubject;
@property (strong, nonatomic, readonly) NSString *emailBody;
@property (strong, nonatomic, readonly) NSString *emailParentID;
@property (strong, nonatomic, readonly) NSString *emailReceivedDate;

+ (instancetype)createFromDict:(NSDictionary *)dict;

- (void)updateFromDict:(NSDictionary *)dict;

@end

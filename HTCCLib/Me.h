//
//  Me.h
//  HTCC Sample
//
//  Created by Arkady on 10/24/13.
//  copyright (c) 2013 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Interaction.h"

@interface Me : NSObject

@property (nonatomic) BOOL loggedIn;
@property (strong, nonatomic) NSString *myID;
@property (strong, nonatomic, readonly) NSMutableArray *devices;
@property (strong, nonatomic, readonly) NSMutableArray *channels;
@property (strong, nonatomic) NSArray *agentStates;
@property (strong, nonatomic, readonly) NSMutableArray *calls;
@property (strong, nonatomic, readonly) NSMutableDictionary *consultCallURIs; //key - Consult Call URI, value - Parent Call URI
@property (strong, nonatomic, readonly) NSMutableArray *chats;
@property (strong, nonatomic, readonly) NSMutableArray *emails;
@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSMutableArray *history;
@property (strong, nonatomic) NSArray *caseData;
@property (strong, nonatomic) NSArray *toastData;
@property (strong, nonatomic) NSArray *dispCodes;
@property (strong, nonatomic) NSArray *emailFromAddresses;
@property (strong, nonatomic) NSDictionary *wsSettings;


+ (instancetype)initMe;

- (void)updateDevices:(NSArray *)newDevices;
- (void)updateChannels:(NSArray *)newChannels;
- (void)updateInteraction:(NSMutableArray *)interArray
           newInteraction:(NSDictionary *)newInteraction
             notification:(NSString *)notificationName;
- (void)updateInteraction:(NSMutableArray *)interArray
           newInteraction:(NSDictionary *)newInteraction
             notification:(NSString *)notificationName
                 userInfo:(NSDictionary *)userInfo;
- (NSString *)makeToastString:(Interaction *)ixn;
- (NSArray *)makeCaseData:(Interaction *)ixn;

@end

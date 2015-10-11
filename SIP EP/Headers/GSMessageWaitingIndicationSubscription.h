//
//  GSMessageWaitingIndicationSubscription.h
//  SipEndpoint
//
//  Created by valery polishchuk on 7/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSEnums.h"

@interface GSMessageWaitingIndicationSubscription : NSObject {
@private
    NSString* user;
    NSString* server;
    NSString* password;
    NSString* transport;    
    int timeout;
    int connectionId;
    int mailboxId;
    GSSubscriptionState state;
}

@property (nonatomic, copy) NSString* user;
@property (nonatomic, copy) NSString* server;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* transport;
@property (nonatomic) int timeout;
@property (nonatomic) int connectionId;
@property (nonatomic) int mailboxId;
@property (nonatomic) GSSubscriptionState state;

- (id)initWithServer:(NSString*) theServer 
                user:(NSString*) theUser 
           transpord:(NSString*) theTransport 
             timeout:(int)theTimeout 
        connectionId:(int)theConnectionId;

- (id)initWithPassword:(NSString*) thePassword 
                server:(NSString*) theServer 
                  user:(NSString*) theUser 
             transpord:(NSString*) theTransport 
               timeout:(int)theTimeout 
          connectionId:(int)theConnectionId;

@end

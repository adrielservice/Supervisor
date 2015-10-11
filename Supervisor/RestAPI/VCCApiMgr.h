//
//  VCCApiMgr.h
//  Supervisor
//
//  Created by David Beilis on 10/3/15.
//  Copyright © 2015 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "UserSession.h"

@protocol UpdateView <NSObject>
- (void) update;
@end

@protocol UpdateStatsView <NSObject>
- (void) update;
@end

@interface VCCApiMgr : NSObject {
    UserSession *userSession;
}

@property (nonatomic, retain) UserSession *userSession;

+ (id)sharedManager;

- (void) configureRestKit;

- (void) registerWithUser:(User*)user callback:(id<UpdateView>)callback;
- (void) getStats;

@end

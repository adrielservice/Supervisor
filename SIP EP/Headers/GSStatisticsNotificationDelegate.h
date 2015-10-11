//
//  GSStatisticsNotificationDelegate.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 9/1/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSStatistics.h"
#import "GSSession.h"

@protocol GSStatisticsNotificationDelegate <NSObject>

- (void) audioStatistics:(GSStatistics*) audioStatistics forSession:(id<GSSession>) session;

- (void) videoStatistics:(GSStatistics*) videoStatistics forSession:(id<GSSession>) session;

@end

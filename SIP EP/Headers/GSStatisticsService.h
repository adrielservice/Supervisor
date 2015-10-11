//
//  GSStatisticsService.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 9/1/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSStatistics.h"
#import "GSStatisticsNotificationDelegate.h"




@protocol GSStatisticsService <NSObject>

- (GSResult) audioStatisticsForSession:(id<GSSession>) session;

- (GSResult) videoStatisticsForSession:(id<GSSession>) session;

- (GSResult) allStatisticsForSession:(id<GSSession>) session;

@property (nonatomic, retain) GSStatistics* audioStatistics;

@property (nonatomic, retain) GSStatistics* videoStatistics;

@property (nonatomic, assign) id<GSStatisticsNotificationDelegate> notificationDelegate;

@end

//
//  GSMediaReport.h
//  SipEndpoint
//
//  Created by Vlad Baranovsky on 3/8/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSMedia.h"

@interface GSMediaReport : NSObject {
    
}
@property (nonatomic, copy) NSString* codecName;

@property (nonatomic, retain) GSMedia* mediaType;

- (void) getValueForStatisticType:(GSMediaStatisticType) statisticType;

@end

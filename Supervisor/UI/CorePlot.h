//
//  CorePlot.h
//  HTCC Sample
//
//  Created by Arkady on 3/28/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlot : NSObject <CPTPlotDataSource>

@property (strong, nonatomic) NSArray *plotData;

+(instancetype)createWithTitle:(NSString *)title;

-(void)renderInView:(UIView *)hostingView animated:(BOOL)animated;

@end

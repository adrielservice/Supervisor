//
//  InterfaceController.h
//  Supervisor WatchKit Extension
//
//  Created by David Beilis on 4/30/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>


@interface InterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet  WKInterfaceLabel *reportTitle;

@property (weak, nonatomic) IBOutlet  WKInterfaceImage *reportVisualization;

- (IBAction)launchVoiceQuery:(id)sender;

@end

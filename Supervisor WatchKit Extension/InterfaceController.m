//
//  InterfaceController.m
//  Supervisor WatchKit Extension
//
//  Created by David Beilis on 4/30/15.
//  Copyright (c) 2015 Genesys. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    
    // Configure interface objects here.
    
    CGFloat width = self.contentFrame.size.width;
    CGFloat height = self.contentFrame.size.height;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)launchVoiceQuery:(id)sender {
    
    NSArray *suggestions = @[
                             @"Queues",
                             @"Agent groups",
                             @"Agents"
                             ];
    
    [self presentTextInputControllerWithSuggestions:suggestions
                                   allowedInputMode:WKTextInputModePlain
                                         completion:^(NSArray *results) {
                                             if (results && results.count > 0) {
                                                 self.reportTitle.text = [results objectAtIndex:0];
                                             }
                                         }];
    
}

@end




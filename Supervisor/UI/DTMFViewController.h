//
//  DialViewController.h
//  HTCC Sample
//
//  Created by Arkady on 11/25/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTMFViewController : UIViewController

@property (strong, nonatomic) void (^operationBlock)(NSString *destination);
@property (nonatomic) BOOL sendDTMF;
@property (weak, nonatomic) UIPopoverController *popoverVC;

@end

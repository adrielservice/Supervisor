//
//  iPadUserDataViewController.h
//  HTCC Sample
//
//  Created by Arkady on 4/1/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserDataViewController <UITableViewDataSource, UITableViewDelegate>

- (void)setUserDataKey:(NSString *)key value:(NSString *)value message:(NSString *)message;

@end

@interface iPadUserDataViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <UserDataViewController>callingVCdelegate;
@property (weak, nonatomic) UIPopoverController *popoverVC;

- (void)reloadData;

@end

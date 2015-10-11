//
//  EmailViewController.h
//  HTCC Sample
//
//  Created by Arkady on 3/12/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"
#import "iPadUserDataViewController.h"

@protocol EmailDelegate <NSObject>
- (void)emailMarkedDone:(Interaction *)ixn;
@end

@interface EmailViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UserDataViewController>

@property (weak, nonatomic) id <EmailDelegate>pageVCdelegate;
@property (strong, nonatomic) Interaction *ixn;

- (void)emailStatusChanged;
- (void)emailUserDataChanged;

@end

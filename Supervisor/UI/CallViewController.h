//
//  CallViewController.h
//  HTCC Sample
//
//  Created by Arkady on 10/26/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"
#import "iPadUserDataViewController.h"

@protocol CallDelegate <NSObject>
- (void)callMarkedDone:(Interaction *)ixn;
- (void)showParentCall:(Interaction *)ixn;
@end

@interface CallViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UserDataViewController>

@property (weak, nonatomic) id <CallDelegate>pageVCdelegate;
@property (strong, nonatomic) Interaction *ixn;

- (void)callChanged;
- (void)attachedDataChanged;
- (void)participantsChanged;


@end

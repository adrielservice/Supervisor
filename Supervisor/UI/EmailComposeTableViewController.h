//
//  EmailComposeTableViewController.h
//  HTCC Sample
//
//  Created by Arkady on 3/19/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"

@interface EmailComposeTableViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Interaction *ixn;

@end

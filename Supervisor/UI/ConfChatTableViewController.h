//
//  ConfChatTableViewController.h
//  HTCC Sample
//
//  Created by Arkady on 12/18/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"

@interface ConfChatTableViewController : UITableViewController

@property (strong, nonatomic) Interaction *ixn;

- (void)participantsChanged;

@end

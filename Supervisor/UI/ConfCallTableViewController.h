//
//  ConferenceTableViewController.h
//  HTCC Sample
//
//  Created by Arkady on 11/20/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"

@interface ConfCallTableViewController : UITableViewController

@property (strong, nonatomic) Interaction *ixn;

- (void)participantsChanged;

@end

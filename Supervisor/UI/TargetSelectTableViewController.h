//
//  TargetSelectTableViewController.h
//  HTCC Sample
//
//  Created by Arkady on 11/9/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"

typedef enum {voice, chat, email} OpsType;

@interface TargetSelectTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) void (^operationBlock)(NSString *destination);
@property (strong, nonatomic) NSString *navTitle;
@property (nonatomic) OpsType opsType;
@property (strong, nonatomic) Interaction *ixn;

@end

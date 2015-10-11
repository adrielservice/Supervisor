//
//  EmailsPageViewController.h
//  HTCC Sample
//
//  Created by Arkady on 3/12/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailViewController.h"

@interface EmailsPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, EmailDelegate>

@end

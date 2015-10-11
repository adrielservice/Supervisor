//
//  CallsPageViewController.h
//  HTCC Sample
//
//  Created by Arkady on 12/2/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallViewController.h"

@interface CallsPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, CallDelegate>

@end

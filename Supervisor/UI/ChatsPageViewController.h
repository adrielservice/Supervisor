//
//  ChatsPageViewController.h
//  HTCC Sample
//
//  Created by Arkady on 12/17/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface ChatsPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ChatDelegate>

@end

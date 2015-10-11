//
//  ChatViewController.h
//  HTCC Sample
//
//  Created by Arkady on 10/29/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "Interaction.h"
#import "iPadUserDataViewController.h"

@protocol ChatDelegate <NSObject>
- (void)chatMarkedDone:(Interaction *)ixn;
@end

@interface ChatViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIBubbleTableViewDataSource, UITableViewDataSource, UITableViewDelegate, UserDataViewController>

@property (weak, nonatomic) id <ChatDelegate>pageVCdelegate;
@property (strong, nonatomic) Interaction *ixn;
@property (nonatomic) BOOL chatActive;

- (void)chatStatusChanged;
- (void)chatParticipantsChanged;
- (void)chatUserDataChanged;
- (void)chatMessagesChanged;
- (void)clearChatTranscript;

@end

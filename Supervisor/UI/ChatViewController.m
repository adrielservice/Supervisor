//
//  ChatViewController.m
//  HTCC Sample
//
//  Created by Arkady on 10/29/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "ChatViewController.h"
#import "ConnectionController.h"
#import "UIBubbleTableView.h"
#import "UIAlertViewBlock.h"
#import "AppDelegate.h"
#import "TargetSelectTableViewController.h"
#import "ConfChatTableViewController.h"

@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *dispCodeTextField;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *chatTableView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *chatButtons;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIButton *confButton;
@property (weak, nonatomic) IBOutlet UIButton *consultButton;
@property (weak, nonatomic) IBOutlet UITableView *attDataTableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIToolbar *dispCodeToolbar;
@property (strong, nonatomic) IBOutlet UIPickerView *dispCodePicker;
@property (weak, nonatomic) IBOutlet UISwitch *consultSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtFieldBottomConstrain;

- (IBAction)markDone:(id)sender;
- (IBAction)endChat:(UIButton *)sender;
- (IBAction)deleteAction:(UIButton *)sender;
- (IBAction)addAction:(UIButton *)sender;
- (IBAction)confAction:(UIButton *)sender;
- (IBAction)dispCancel:(UIBarButtonItem *)sender;
- (IBAction)dispSet:(UIBarButtonItem *)sender;
- (IBAction)consultSwitchChanged:(UISwitch *)sender;

@end

@implementation ChatViewController {
    // instance variables declared in implementation context
    NSMutableArray *localBubbleData;            //displayed in UIBubbleTableView, synchronized with remoteBubbleData
    NSMutableArray *remoteBubbleData;           //received by CometD
    UIAlertViewBlock *alert;
    NSArray *caseData2Show;
    BOOL editingAttachedData;
    ConfChatTableViewController *confVC;
    iPadUserDataViewController *userDataVC;
    BOOL keyboardIsShown;
}


#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _doneButton.hidden = YES;
    
    if (localBubbleData == nil) {
        localBubbleData = [[NSMutableArray alloc] init];
    }
    
    if (remoteBubbleData == nil) {
        remoteBubbleData = [[NSMutableArray alloc] init];
    }
    
	// Do any additional setup after loading the view.
    
    _chatTableView.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    _chatTableView.snapInterval = 120;
    
    // The line below disables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    // @DB - no a public API
    // _chatTableView.showAvatars = NO;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNobody - no "now typing" bubble
    
    _chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    
    //Set up the date picker as the Date text field input view
    _dispCodeTextField.inputView = _dispCodePicker;
    _dispCodeTextField.inputAccessoryView = _dispCodeToolbar;
    _dispCodeTextField.hidden = YES;
    [self hideConsultSwitch];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
   }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _chatTableView.bubbleDataSource = nil;
    localBubbleData = nil;
    remoteBubbleData = nil;
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [localBubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [localBubbleData objectAtIndex:row];
}

#pragma mark - TextField delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": [self consultActive] ? @"SendStartTypingToAgentsNotification" : @"SendStartTypingNotification"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": [self consultActive] ? @"SendStopTypingToAgentsNotification" : @"SendStopTypingNotification"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

//Dismiss keyboard when Return key is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    _chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    
    if ([_textField.text length] > 0) {
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (_ixn.ixnID) {
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": [self consultActive] ? @"SendToAgents" : @"SendMessage",
                                                      @"text" : _textField.text}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];

        }
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:_textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        [localBubbleData addObject:sayBubble];
        [_chatTableView reloadData];
        
        // @DB - no a public API
        //[_chatTableView scrollBubbleViewToBottomAnimated:YES];
    }
    
    _textField.text = @"";
    [_textField resignFirstResponder];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (!keyboardIsShown) {
        //Get the size of the keyboard
        NSDictionary* userInfo = [n userInfo];
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardFrameConverted = [self.view.window convertRect:keyboardFrame toView:self.view];
        CGSize keyboardSize = keyboardFrameConverted.size;
        
        //Move textField and consultSwitch up
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        _txtFieldBottomConstrain.constant += (keyboardSize.height - self.tabBarController.tabBar.frame.size.height - 36.);
        
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
        
        keyboardIsShown = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)n
{
    if (keyboardIsShown) {
        //Get the size of the keyboard
        NSDictionary* userInfo = [n userInfo];
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardFrameConverted = [self.view.window convertRect:keyboardFrame toView:self.view];
        CGSize keyboardSize = keyboardFrameConverted.size;
        
        //Move textField and consultSwitch down
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        _txtFieldBottomConstrain.constant -= (keyboardSize.height - self.tabBarController.tabBar.frame.size.height - 36.);
        
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
        
        keyboardIsShown = NO;
    }
}


#pragma mark - Cometd Events

- (void)chatStatusChanged {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");
    
    //remove previous alert
    [alert dismissWithClickedButtonIndex:-1 animated:NO];

    if ([_ixn.state isEqualToString:@"Invited"]) {
        // Display Alert
        if (_ixn.ixnID && [_ixn.capabilities containsObject:@"Accept"]) {
            alert = [[UIAlertViewBlock alloc]
                     initWithTitle:@"Incoming Chat"
                     message:[appDelegate.htccConnection.me makeToastString:_ixn]
                     completion:^(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView *av) {
                         if (cancelPressed) {
                             // Reject
                             [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                                              method:@"POST"
                                                              params:@{@"operationName": @"Reject"}
                                                                user:appDelegate.htccUser
                                                            password:appDelegate.htccPassword
                                                   completionHandler:nil];
                         }
                         else  if (buttonIndex == 1){
                             // Accept
                             _chatActive = YES;
                             [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                                              method:@"POST"
                                                              params:@{@"operationName": @"Accept",
                                                                       @"nickname": appDelegate.htccUser}
                                                                user:appDelegate.htccUser
                                                            password:appDelegate.htccPassword
                                                   completionHandler:nil];
                         }
                     }
                     cancelButtonTitle:@"Reject"
                     otherButtonTitles:@"Accept", nil];
            //  alert.dismissTimeout = 30.;
            [alert show];
        }
    }
    else if ([_ixn.state isEqualToString:@"Chatting"]) {
        [self updateChatUIDisplay];
    }
    else if ([_ixn.state isEqualToString:@"Revoked"] || [_ixn.state isEqualToString:@"Completed"]) {
        _chatActive = NO;
        [_pageVCdelegate chatMarkedDone:_ixn];
    }
    else if ([_ixn.state isEqualToString:@"LeftChat"]) {
        _chatActive = NO;
        [self updateChatUIDisplay];
    }
}

- (void)chatParticipantsChanged {
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");
    
    if (![[_ixn.participants valueForKey:@"type"] containsObject:@"Customer"]) {
        //Customer left, chat ended
        _chatActive = NO;
    }
    else {
        [confVC participantsChanged];
    }
    
    [self updateChatUIDisplay];
}

- (void)chatUserDataChanged {
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");

    [_attDataTableView reloadData];
    [userDataVC reloadData];
    [self updateChatUIDisplay];
}

- (void)addMsgFromSomeone:(NSDictionary *)message {
     NSString *msg = message[@"text"];
    if ([message[@"visibility"] isKindOfClass:[NSString class]] && [message[@"visibility"] isEqualToString:@"Agents"])
        msg = [msg stringByAppendingString:@" [Consult]"];
    NSBubbleData *rcvBubble = [NSBubbleData dataWithText:msg
                                                    date:[NSDate dateWithTimeIntervalSinceNow:0]
                                                    type:BubbleTypeSomeoneElse];
    [localBubbleData addObject:rcvBubble];
    [remoteBubbleData addObject:rcvBubble];
    _chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    [_chatTableView reloadData];
    // @DB - no a public API
    // [_chatTableView scrollBubbleViewToBottomAnimated:YES];
}

- (void)addMsgFromMe:(NSDictionary *)message {
     NSString *msg = message[@"text"];
    if ([message[@"visibility"] isKindOfClass:[NSString class]] && [message[@"visibility"] isEqualToString:@"Agents"])
        msg = [msg stringByAppendingString:@" [Consult]"];
    NSBubbleData *rcvBubble = [NSBubbleData dataWithText:msg
                                                    date:[NSDate dateWithTimeIntervalSinceNow:0]
                                                    type:BubbleTypeMine];
    [remoteBubbleData addObject:rcvBubble];
    if (![localBubbleData isEqual:remoteBubbleData]) {
        //Sync
        NSLog(@"Synchronized remote chat messages order...");
        localBubbleData = [NSMutableArray arrayWithArray:remoteBubbleData];
        [_chatTableView reloadData];
        // @DB - no a public API
        // [_chatTableView scrollBubbleViewToBottomAnimated:YES];
    }
}

- (void)chatMessagesChanged {
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    for (NSDictionary *message in _ixn.messages) {

        if ([message isKindOfClass:[NSDictionary class]]) {
            if (![message[@"type"] isKindOfClass:[NSString class]] ||
                ![message[@"from"] isKindOfClass:[NSDictionary class]])
                continue;

            if ([message[@"type"] isEqualToString:@"ParticipantJoined"] &&
                ![message[@"from"][@"nickname"] isEqualToString:@"system"]) {
                self.navigationItem.title = [NSString stringWithFormat:@"%@ joined", message[@"from"][@"nickname"]];
            }
            else if ([message[@"type"] isEqualToString:@"ParticipantLeft"] &&
                     [message[@"from"][@"nickname"] isKindOfClass:[NSString class]] &&
                     ![message[@"from"][@"nickname"] isEqualToString:@"system"]) {
                self.navigationItem.title = [NSString stringWithFormat:@"%@ left", message[@"from"][@"nickname"]];
            }
            else if ([message[@"type"] isEqualToString:@"Text"] &&
                     [message[@"from"][@"type"] isKindOfClass:[NSString class]] &&
                     [message[@"from"][@"type"] isEqualToString:@"Customer"]) {
                // Display new message from CLIENT
                [self addMsgFromSomeone:message];
            }
            else if ([message[@"type"] isEqualToString:@"Text"] &&
                     [message[@"from"][@"type"] isKindOfClass:[NSString class]] &&
                     [message[@"from"][@"type"] isEqualToString:@"Agent"]) {
                if ([message[@"from"][@"uri"] isKindOfClass:[NSString class]] &&
                    [[[message[@"from"][@"uri"] pathComponents] lastObject] isEqualToString:appDelegate.htccConnection.me.myID])
                    // Display new message from ourself.
                    [self addMsgFromMe:message];
                else
                    // Display new message from another AGENT
                    [self addMsgFromSomeone:message];
                
            }
            else if ([message[@"type"] isEqualToString:@"TypingStarted"] && [message[@"from"][@"type"] isKindOfClass:[NSString class]]) {
                if ([message[@"from"][@"type"] isEqualToString:@"Customer"] ||
                    ([message[@"from"][@"type"] isEqualToString:@"Agent"] &&
                     [message[@"from"][@"uri"] isKindOfClass:[NSString class]] &&
                    ![[[message[@"from"][@"uri"] pathComponents] lastObject] isEqualToString:appDelegate.htccConnection.me.myID])) {
                    _chatTableView.typingBubble = NSBubbleTypingTypeSomebody;
                    [_chatTableView reloadData];
                    // @DB - no a public API
                    // [_chatTableView scrollBubbleViewToBottomAnimated:YES];
                }
            }
            else if ([message[@"type"] isEqualToString:@"TypingStopped"]) {
                _chatTableView.typingBubble = NSBubbleTypingTypeNobody;
                [_chatTableView reloadData];
                // @DB - no a public API
                // [_chatTableView scrollBubbleViewToBottomAnimated:YES];
            }
        }
    }
    [self updateChatUIDisplay];
}

#pragma mark - Actions

- (IBAction)markDone:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Verify Disposition is set if it's mandatory
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-mandatory"] boolValue] && [_dispCodePicker selectedRowInComponent:0] <= 0) {
        [self displayError:@"Disposition is required"];
    }
    else if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Complete"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
        [localBubbleData removeAllObjects];
        [remoteBubbleData removeAllObjects];
        [_chatTableView reloadData];
        
        caseData2Show = nil;
        [_attDataTableView reloadData];
    }
}

- (IBAction)endChat:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Leave"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
    
    _chatActive = NO;
    [self updateChatUIDisplay];
}

- (IBAction)deleteAction:(UIButton *)sender {
    editingAttachedData = !editingAttachedData;
    [_deleteButton setTitle:(editingAttachedData) ? @"Done": @"Delete" forState:UIControlStateNormal];
    [_attDataTableView setEditing:editingAttachedData animated:YES];
}

- (void)setUserDataKey:(NSString *)key value:(NSString *)value message:(NSString *)message {
    alert = [[UIAlertViewBlock alloc] initWithTitle:@"Set Attached Data"
                                            message:message
                                         completion:^(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView *av) {
                                             if (buttonIndex == 1){
                                                 // Add
                                                 if ([av textFieldAtIndex:0].text.length == 0) {
                                                     [self setUserDataKey:[av textFieldAtIndex:0].text value:[av textFieldAtIndex:1].text message:@"Error - Key is required"];
                                                 }
                                                 else if ([av textFieldAtIndex:1].text.length == 0) {
                                                     [self setUserDataKey:[av textFieldAtIndex:0].text value:[av textFieldAtIndex:1].text message:@"Error - Value is required"];
                                                 }
                                                 else {
                                                     AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                     if (_ixn.ixnID) {
                                                         [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                                                                          method:@"POST"
                                                                                          params:@{@"operationName": @"UpdateUserData",
                                                                                                   @"userData" :
                                                                                                       @{[av textFieldAtIndex:0].text: [av textFieldAtIndex:1].text}
                                                                                                   }
                                                                                            user:appDelegate.htccUser
                                                                                        password:appDelegate.htccPassword
                                                                               completionHandler:nil];
                                                     }
                                                 }
                                             }
                                         }
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:message, nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alert textFieldAtIndex:0] setPlaceholder:@"Key"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"Value"];
    if (key.length)
        [[alert textFieldAtIndex:0] setText:key];
    if (value.length)
        [[alert textFieldAtIndex:1] setText:value];
    [alert show];
}


- (IBAction)addAction:(UIButton *)sender {
    [self setUserDataKey:nil value:nil message:@"Add"];
}

- (IBAction)confAction:(UIButton *)sender {
    NSInteger maxp = [[_ixn.participants valueForKey:@"nickname"] containsObject:@"system"] ? 3 : 2;
    if (_ixn.participants.count > maxp) {
        [self performSegueWithIdentifier:@"confChat" sender:self];
    }
    else
        [self performSegueWithIdentifier:@"chatConfTargetSelect" sender:self];
}

- (IBAction)dispCancel:(UIBarButtonItem *)sender {
    [_dispCodeTextField resignFirstResponder];
}

- (IBAction)dispSet:(UIBarButtonItem *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger selRow = [_dispCodePicker selectedRowInComponent:0];
    _dispCodeTextField.text = (selRow <= 0) ? nil : appDelegate.htccConnection.me.dispCodes[selRow - 1][@"displayName"];
    [_dispCodeTextField resignFirstResponder];
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-read-only-on-idle"] boolValue] && !_chatActive) {
        [self displayError:@"Disposition can be set only when chat is active"];
        _dispCodeTextField.hidden = YES;
    }
    else {
        self.navigationItem.prompt = nil;
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithCapacity:1];
        
        [body setDictionary:@{@"operationName": @"SetDisposition",
                               @"disposition":appDelegate.htccConnection.me.dispCodes[selRow - 1][@"name"]}];
        
        if (appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.key-name"]) {
            [body addEntriesFromDictionary:@{@"dispositionKey": appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.key-name"]}];
        }
        
        if (_ixn.ixnID) {
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:body
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        }
    }
}

- (IBAction)consultSwitchChanged:(UISwitch *)sender {
    [self updateChatUIDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([segue.identifier isEqualToString:@"chatTransferTargetSelect"]) {
        // Perform transfer
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            NSString *uri = [appDelegate.htccURL stringByAppendingPathComponent:@"api/v2/users"];
            uri = [uri stringByAppendingPathComponent:dest];
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Transfer", @"targetUri": uri}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = chat;
        targetVC.navTitle = @"Chat Transfer";
        targetVC.ixn = _ixn;
    }
    if ([segue.identifier isEqualToString:@"chatConfTargetSelect"]) {
        // Perform conference
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            NSString *uri = [appDelegate.htccURL stringByAppendingPathComponent:@"api/v2/users"];
            uri = [uri stringByAppendingPathComponent:dest];
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Invite", @"targetUri": uri}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = chat;
        targetVC.navTitle = @"Chat Conference";
        targetVC.ixn = _ixn;
    }
    if ([segue.identifier isEqualToString:@"chatConsultTargetSelect"]) {
        // Perform consult
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            NSString *uri = [appDelegate.htccURL stringByAppendingPathComponent:@"api/v2/users"];
            uri = [uri stringByAppendingPathComponent:dest];
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Consult", @"targetUri": uri}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = chat;
        targetVC.navTitle = @"Chat Consult";
        targetVC.ixn = _ixn;
    }
    if ([segue.identifier isEqualToString:@"confChat"]) {
        // Perform Conf Call
        ConfChatTableViewController *targetVC = segue.destinationViewController;
        targetVC.ixn = _ixn;
        confVC = targetVC;
    }
    else if ([segue.identifier isEqualToString:@"chatUserDataPopover"]) {
        // Display User Data popover for iPad
        UIPopoverController *popVC = ((UIStoryboardPopoverSegue *)(segue)).popoverController;
        userDataVC = (iPadUserDataViewController *)popVC.contentViewController;
        userDataVC.callingVCdelegate = self;
        userDataVC.popoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
}

#pragma mark - UI

- (BOOL)consultActive {
    return ([[_ixn.participants valueForKey:@"visibility"] containsObject:@"Agents"] && _consultSwitch.on);
}

- (void)showConsultSwitch
{
    if (_consultSwitch.hidden == YES) {
        _consultSwitch.hidden = NO;
        CGRect frameRect = _textField.frame;
        frameRect.size.width -= _consultSwitch.frame.size.width;
        _textField.frame = frameRect;
        [self.view layoutIfNeeded];
    }
}

- (void)hideConsultSwitch
{
    if (_consultSwitch.hidden == NO) {
        _consultSwitch.hidden = YES;
        CGRect frameRect = _textField.frame;
        frameRect.size.width += _consultSwitch.frame.size.width;
        _textField.frame = frameRect;
        [self.view layoutIfNeeded];
    }
}

- (void)updateChatUIDisplay
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _addButton.hidden = (appDelegate.htccConnection.me.caseData.count && [_ixn.capabilities containsObject:@"UpdateUserData"]) ? NO : YES;
    _deleteButton.hidden = (appDelegate.htccConnection.me.caseData.count && [_ixn.capabilities containsObject:@"DeleteUserData"]) ? NO : YES;
    
    if (appDelegate.htccConnection.me.caseData) {
        // Display attached data
        caseData2Show = [appDelegate.htccConnection.me makeCaseData:_ixn];
        [_attDataTableView reloadData];
    }

    _dispCodeTextField.hidden = (appDelegate.htccConnection.me.dispCodes.count && [_ixn.capabilities containsObject:@"SetDisposition"]) ? NO : YES;

    if (_chatActive) {
        _doneButton.hidden = YES;
        _endButton.enabled = [_ixn.capabilities containsObject:@"Leave"] ? YES : NO;
        _textField.enabled = [_ixn.capabilities containsObject:@"SendMessage"] ? YES : NO;
        _transferButton.enabled = [_ixn.capabilities containsObject:@"Transfer"] ? YES : NO;
        _confButton.enabled = [_ixn.capabilities containsObject:@"Invite"] ? YES : NO;
        _consultButton.enabled = [_ixn.capabilities containsObject:@"Consult"] ? YES : NO;
        
        BOOL consultAgentsPresent = [[_ixn.participants valueForKey:@"visibility"] containsObject:@"Agents"];
        if (consultAgentsPresent)
            [self showConsultSwitch];
        else
            [self hideConsultSwitch];
        
        _textField.placeholder = [self consultActive] ?  @"Type Consult Message Here" : @"Type Chat Message Here";
        _textField.backgroundColor = [self consultActive] ? [UIColor colorWithRed:31./255. green:118./255. blue:227./255. alpha:0.25] : [UIColor whiteColor];
    }
    else {
        _doneButton.hidden = [_ixn.capabilities containsObject:@"Complete"] ? NO : YES;
        self.navigationItem.title = @"Chat Ended";
        [_chatButtons setValue:@FALSE forKey:@"enabled"];
        _textField.enabled = FALSE;
    }
}

- (void)displayError:(NSString *)errStr
{
    self.navigationItem.prompt = errStr;
    double delayInSeconds = 10.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.prompt = nil;
    });
}

- (void)clearChatTranscript
{
    [localBubbleData removeAllObjects];
    [remoteBubbleData removeAllObjects];
    [_chatTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_ixn.userData.count) ? caseData2Show.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"attachedDataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = caseData2Show[indexPath.row][@"displayName"];
    cell.detailTextLabel.text = _ixn.userData[caseData2Show[indexPath.row][@"name"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setUserDataKey:caseData2Show[indexPath.row][@"name"]
                   value:_ixn.userData[caseData2Show[indexPath.row][@"name"]]
                 message:@"Update"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table View Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"DeleteUserData", @"keys" : @[caseData2Show[indexPath.row][@"name"]]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}


#pragma mark - Picker View Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (appDelegate.htccConnection.me.dispCodes.count + 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (row == 0) ? @"None" : appDelegate.htccConnection.me.dispCodes[row - 1][@"displayName"];
}

@end

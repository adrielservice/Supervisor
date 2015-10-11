//
//  CallViewController.m
//  HTCC Sample
//
//  Created by Arkady on 10/26/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "CallViewController.h"
#import "ConnectionController.h"
#import "AppDelegate.h"
#import "UIAlertViewBlock.h"
#import "TargetSelectTableViewController.h"
#import "Contact.h"
#import "DTMFViewController.h"
#import "ConfCallTableViewController.h"

@interface CallViewController ()
@property (weak, nonatomic) IBOutlet UILabel *aniLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *holdButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIButton *confButton;
@property (weak, nonatomic) IBOutlet UIButton *consultButton;
@property (weak, nonatomic) IBOutlet UIButton *dialButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *callButtons;
@property (strong, nonatomic) IBOutlet UIPickerView *dispCodePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *dispCodeToolBar;
@property (weak, nonatomic) IBOutlet UITextField *dispCodeTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *addDeleteButtons;
@property (weak, nonatomic) IBOutlet UIButton *userDataButton;

- (IBAction)endCall:(UIButton *)sender;
- (IBAction)holdCall:(UIButton *)sender;
- (IBAction)transferCall:(UIButton *)sender;
- (IBAction)confCall:(UIButton *)sender;
- (IBAction)markDone:(UIButton *)sender;
- (IBAction)dispCancel:(UIBarButtonItem *)sender;
- (IBAction)dispSet:(UIBarButtonItem *)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)addAction:(id)sender;

@end

@implementation CallViewController {
    // instance variables declared in implementation context
    NSTimer *timer;
    NSTimeInterval callDuration;
    UIAlertViewBlock *alert;
    BOOL callOnHold;
    BOOL editingAttachedData;
    NSArray *caseData2Show;
    ConfCallTableViewController *confVC;
    iPadUserDataViewController *userDataVC;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _doneButton.hidden = YES;
    
    //Set up the date picker as the Date text field input view
    _dispCodeTextField.inputView = _dispCodePicker;
    _dispCodeTextField.inputAccessoryView = _dispCodeToolBar;
    _dispCodeTextField.hidden = YES;
    [_addDeleteButtons setValue:@YES forKey:@"hidden"];
    _userDataButton.hidden = YES;
    
    //Outlets are not updated if callChanged was called before viewDidLoad, so refresh them
    [self updateCallUIDisplay];
    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    appDelegate.htccConnection.me.call = @{@"state": @"Established",
//                            @"userData" : @{@"GMS_Service_ID": @"12345",
//                                            @"GMS_UserData": @"7890"}
//                            };    
}

#pragma mark - Call Status update delegates

- (void)callChanged
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");

    //remove previous alert
    [alert dismissWithClickedButtonIndex:-1 animated:NO];
    
    if ([_ixn.state isEqualToString:@"Preview"] && [_ixn.capabilities containsObject:@"Accept"]) {
        alert = [[UIAlertViewBlock alloc]
                 initWithTitle:[NSString stringWithFormat:@"Preview Call\n%@", [self makeParticipantsString]]
                 message:[appDelegate.htccConnection.me makeToastString:_ixn]
                 completion:^(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView *av) {
                     if (cancelPressed)
                         // Decline
                         [self declinePreview];
                     else if (buttonIndex == 1)
                         [self acceptPreview];
                 }
                 cancelButtonTitle:@"Decline"
                 otherButtonTitles:@"Accept", nil];
        alert.dismissTimeout = 30.;
        [alert show];
    }

    if ([_ixn.state isEqualToString:@"PreviewCancelled"]) {
        [_pageVCdelegate callMarkedDone:_ixn];
    }
    
    if ([_ixn.state isEqualToString:@"Ringing"]) {
        if ([_ixn.capabilities containsObject:@"Answer"]) {
            alert = [[UIAlertViewBlock alloc]
                     initWithTitle:[NSString stringWithFormat:@"Incoming Call\n%@", [self makeParticipantsString]]
                     message:[appDelegate.htccConnection.me makeToastString:_ixn]
                     completion:^(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView *av) {
                         if (cancelPressed) {
                             // Release
                             [self endCall:nil];
                         }
                         else if (buttonIndex == 1){
                             [self answerCall];
                         }
                     }
                     cancelButtonTitle:@"Release"
                     otherButtonTitles:@"Answer", nil];
            alert.dismissTimeout = 30.;
            [alert show];
        }
        [self updateCallUIDisplay];
    }
    else if ([_ixn.state isEqualToString:@"Held"]) {
        callOnHold = TRUE;
        [self updateCallUIDisplay];
    }
    else if ([_ixn.state isEqualToString:@"Established"]) {
        
        if (callOnHold) {
            callOnHold = FALSE;
        }
        else {
            // Start timer, display attached data, enable Call Control buttons
            _timerLabel.text = @"00:00:00";
            [self startTimer];
        }
        
        if ([_ixn.callType isEqualToString:@"Consult"]) {
            //Update Consult call UI
            [self updateCallUIDisplay];
            //Tell PageView Controller to display Parent Call
            [_pageVCdelegate showParentCall:_ixn];
        }
        
        [self updateCallUIDisplay];
    }
    else if ([_ixn.state isEqualToString:@"Released"]) {
        
        [self updateCallUIDisplay];
        
        // Stop timer, disable "Active" Tab
        [self stopTimer];
        if ([appDelegate.htccConnection.me.wsSettings[@"voice.mark-done-on-release"] boolValue])
            [self markDone:_doneButton];
        else
            _doneButton.hidden = NO;
    }
}

- (void)attachedDataChanged
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");

    caseData2Show = [appDelegate.htccConnection.me makeCaseData:_ixn];
    [_tableView reloadData];
    [userDataVC reloadData];
}

- (void)participantsChanged
{
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");

    _aniLabel.text = [self makeParticipantsString];
    [confVC participantsChanged];
}

- (NSString *)makeParticipantsString
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    __block NSString *partStr = @"";
    [_ixn.participants enumerateObjectsUsingBlock:^(id participant, NSUInteger idx, BOOL *stop) {
        if (participant) {
            NSInteger idx = [appDelegate.htccConnection.me.contacts indexOfObjectPassingTest:^BOOL(id contact, NSUInteger idx, BOOL *stop) {
                if ([((Contact *)contact).phoneNumber isEqualToString:participant[@"phoneNumber"]]) {
                    *stop = YES;
                    return TRUE;
                }
                else
                    return FALSE;
            }];
            if (idx == NSNotFound && participant[@"formattedPhoneNumber"])
                partStr = [partStr stringByAppendingString:participant[@"formattedPhoneNumber"]];
            else if ([appDelegate.htccConnection.me.contacts[idx] name])
                partStr = [partStr stringByAppendingString:[appDelegate.htccConnection.me.contacts[idx] name]];
        }
        if (idx < _ixn.participants.count - 1) {
            partStr = [partStr stringByAppendingString:@", "];
        }
    }];
    return partStr;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}


#pragma mark - UI

- (void)enableRetrieveButton
{
    _holdButton.enabled = TRUE;
    // Display "Retrieve Call" button
    [_holdButton setImage:[UIImage imageNamed:@"retrieve call"] forState:UIControlStateNormal];
    [_holdButton setTitle:@"Retrieve" forState:UIControlStateNormal];
    _holdButton.imageEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, -40);
}

- (void)enableHoldButton
{
    _holdButton.enabled = TRUE;
    // Display "Hold Call" button
    [_holdButton setImage:[UIImage imageNamed:@"hold call"] forState:UIControlStateNormal];
    [_holdButton setTitle:@"Hold" forState:UIControlStateNormal];
    _holdButton.imageEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, -20);
}

- (void)updateCallUIDisplay
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.navigationItem.title = _ixn.state;
    _aniLabel.text = [self makeParticipantsString];
    [_addDeleteButtons setValue:(appDelegate.htccConnection.me.caseData.count) ? @NO : @YES forKey:@"hidden"];
    _userDataButton.hidden = (appDelegate.htccConnection.me.caseData.count) ? NO : YES;

    if (appDelegate.htccConnection.me.caseData) {
        // Display attached data
        caseData2Show = [appDelegate.htccConnection.me makeCaseData:_ixn];
        [_tableView reloadData];
   }
    
    if (appDelegate.htccConnection.me.dispCodes.count) {
        _dispCodeTextField.text = nil;
        _dispCodeTextField.hidden = NO;
    }
    
    [self disableCallControlButtons];
    
    _endButton.enabled = ([_ixn.capabilities containsObject:@"Hangup"]) ? TRUE : FALSE;
    if ([_ixn.state isEqualToString:@"Established"] || callOnHold) {
        if ([_ixn.capabilities containsObject:@"Hold"] || ([_ixn.capabilities containsObject:@"SwapCalls"] && !callOnHold)) {
            [self enableHoldButton];
        }
        if ([_ixn.capabilities containsObject:@"Retrieve"] || ([_ixn.capabilities containsObject:@"SwapCalls"] && callOnHold)) {
            [self enableRetrieveButton];
        }
        if (([_ixn.capabilities containsObject:@"SingleStepTransfer"] || [_ixn.capabilities containsObject:@"CompleteTransfer"])) {
            _transferButton.enabled = YES;
        }
        if (([_ixn.capabilities containsObject:@"SingleStepConference"] || [_ixn.capabilities containsObject:@"CompleteConference"])) {
            _confButton.enabled = YES;
        }
        if (([_ixn.capabilities containsObject:@"InitiateConference"] ||[_ixn.capabilities containsObject:@"InitiateTransfer"])) {
            _consultButton.enabled = YES;
        }
        if ([_ixn.capabilities containsObject:@"SendDtmf"]) {
            _dialButton.enabled = YES;
        }
    }
}

- (void)disableCallControlButtons
{
    [_callButtons setValue:@FALSE forKey:@"enabled"];
}

#pragma mark - Timer

- (void)startTimer
{
    NSLog(@"Timer Started!");
    callDuration = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    NSLog(@"Timer Stopped!");
    [timer invalidate];
}

- (void)timerTick:(NSTimer *)tt {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.calls.count == 0) {
        [tt invalidate];
    }
    else if (!callOnHold) {
        _timerLabel.text = [self stringFromTimeInterval:callDuration++];
    }
}

#pragma mark - Call Control Actions

- (void)acceptPreview
{
    // Accept
    if (_ixn.ixnID) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Accept"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (void)declinePreview
{
    // Accept
    if (_ixn.ixnID) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Decline"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
        [_pageVCdelegate callMarkedDone:_ixn];
    }
}

- (void)answerCall
{
    // Answer
    if (_ixn.ixnID) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Answer"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (IBAction)endCall:(UIButton *)sender {

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //To prevent multiple "End Call" clicks
    [self disableCallControlButtons];

    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Hangup"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (NSString *)otherCallURI {
    //Returns Consult or Parent URI or an empty string
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.htccConnection.me.consultCallURIs[_ixn.uri])
        //"Other" is Parent Call
        return(appDelegate.htccConnection.me.consultCallURIs[_ixn.uri]);
    else {
        //"Other" is Consult Call
        NSArray *keys = [appDelegate.htccConnection.me.consultCallURIs allKeysForObject:_ixn.uri];
        return (keys.count > 0) ? keys[0] : @"";
    }
}

- (IBAction)holdCall:(UIButton *)sender {
    // Hold, Retrieve or Swap Call
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    NSDictionary *params;
    
    if ([_ixn.capabilities containsObject:@"SwapCalls"]) {
        params = @{@"operationName": @"SwapCalls", @"otherCallUri": [self otherCallURI]};
    }
    else if ([_ixn.capabilities containsObject:@"Hold"]) {
        params = @{@"operationName": @"Hold"};
    }
    else if ([_ixn.capabilities containsObject:@"Retrieve"]) {
        params = @{@"operationName": @"Retrieve"};
    }
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:params
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (IBAction)transferCall:(UIButton *)sender {
    if ([self otherCallURI].length == 0) {
        //There is no Consult Call
        [self performSegueWithIdentifier:@"targetSelectTransfer" sender:self];
    }
    else
    {
        //Complete Transfer
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"CompleteTransfer"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (IBAction)confCall:(UIButton *)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    if (self.otherCallURI.length == 0) {
        //There is no Consult Call
        if (appDelegate.htccConnection.me.calls.count && _ixn.participants.count > 1)
            [self performSegueWithIdentifier:@"confCall" sender:self];
        else
            [self performSegueWithIdentifier:@"targetSelectConf" sender:self];
    }
    else
    {
        //Complete Transfer
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"CompleteConference"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    if ([segue.identifier isEqualToString:@"targetSelectTransfer"]) {
        // Perform Single-Step transfer
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
             [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"SingleStepTransfer", @"destination" : @{@"phoneNumber" : dest}}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = voice;
        targetVC.navTitle = @"Transfer";
        targetVC.ixn = _ixn;
    }
    else if ([segue.identifier isEqualToString:@"targetSelectConf"]) {
        // Perform Single-Step conference
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"SingleStepConference", @"destination" : @{@"phoneNumber" : dest}}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = voice;
        targetVC.navTitle = @"Conference";
        targetVC.ixn = _ixn;
    }
    else if ([segue.identifier isEqualToString:@"targetSelectConsult"]) {
        // Perform Two-Step conference or transfer
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"InitiateTransfer", @"destination" : @{@"phoneNumber" : dest}}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = voice;
        targetVC.navTitle = @"Consult";
        targetVC.ixn = _ixn;
    }
    else if ([segue.identifier isEqualToString:@"dtmfSend"]) {
        // Send DTMF
        DTMFViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"SendDtmf", @"digits": dest}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.sendDTMF = YES;
    }
    else if ([segue.identifier isEqualToString:@"dtmfSendPopover"]) {
        // Send DTMF iPad
        UINavigationController *navVC = segue.destinationViewController;
        DTMFViewController *targetVC = (DTMFViewController *)navVC.topViewController;
        targetVC.popoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
        targetVC.operationBlock = ^(NSString *dest){
            [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"SendDtmf", @"digits": dest}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.sendDTMF = YES;
    }
    else if ([segue.identifier isEqualToString:@"confCall"]) {
        // Perform Conf Call
        ConfCallTableViewController *targetVC = segue.destinationViewController;
        targetVC.ixn = _ixn;
        confVC = targetVC;
    }
    else if ([segue.identifier isEqualToString:@"callUserDataPopover"]) {
        // Display User Data popover for iPad
        UIPopoverController *popVC = ((UIStoryboardPopoverSegue *)(segue)).popoverController;
        userDataVC = (iPadUserDataViewController *)popVC.contentViewController;
        userDataVC.callingVCdelegate = self;
        userDataVC.popoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
}

- (IBAction)markDone:(UIButton *)sender {
    //Verify Disposition is set if it's mandatory
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-mandatory"] boolValue] && [_dispCodePicker selectedRowInComponent:0] <= 0) {
        [self displayError:@"Disposition is required"];
    }
    else {
        //Mark Interaction "Done"
        [_pageVCdelegate callMarkedDone:_ixn];
    }
}

- (IBAction)dispSet:(UIBarButtonItem *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger selRow = [_dispCodePicker selectedRowInComponent:0];
    _dispCodeTextField.text = (selRow <= 0) ? nil : appDelegate.htccConnection.me.dispCodes[selRow - 1][@"displayName"];
    [_dispCodeTextField resignFirstResponder];
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-read-only-on-idle"] boolValue] &&
        [_ixn.state isEqualToString:@"Released"]) {
        [self displayError:@"Disposition can be set only when call is active"];
        _dispCodeTextField.hidden = YES;
    }
    else if (selRow > 0) {
        self.navigationItem.prompt = nil;
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithCapacity:1];
        
        [body setDictionary:@{@"operationName": @"SetCallDisposition",
                              @"callUri":_ixn.uri,
                              @"callUuid":_ixn.callUuid,
                              @"disposition":appDelegate.htccConnection.me.dispCodes[selRow - 1][@"name"]}];
        
        if (appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.key-name"]) {
            [body addEntriesFromDictionary:@{@"dispositionKey": appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.key-name"]}];
        }

        if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.use-attached-data"] boolValue] && _ixn.userData) {
            [body addEntriesFromDictionary:@{@"userData": _ixn.userData}];
        }
        
        if ([_ixn.deviceUri lastPathComponent]) {
            [appDelegate.htccConnection submit2HTCC:[kMeDevicesURL stringByAppendingString:[_ixn.deviceUri lastPathComponent]]
                                             method:@"POST"
                                             params:body
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        }
    }
}

- (IBAction)deleteAction:(id)sender {
    editingAttachedData = !editingAttachedData;
    [_deleteButton setTitle:(editingAttachedData) ? @"Done": @"Delete" forState:UIControlStateNormal];
    [_tableView setEditing:editingAttachedData animated:YES];
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
                                                         [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
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

- (IBAction)dispCancel:(UIBarButtonItem *)sender {
    [_dispCodeTextField resignFirstResponder];
}

- (void)displayError:(NSString *)errStr {
    self.navigationItem.prompt = errStr;
    double delayInSeconds = 10.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.prompt = nil;
    });
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
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"DeleteUserDataPair", @"key" : caseData2Show[indexPath.row][@"name"]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

@end

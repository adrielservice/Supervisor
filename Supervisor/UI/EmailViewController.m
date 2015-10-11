//
//  EmailViewController.m
//  HTCC Sample
//
//  Created by Arkady on 3/12/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "EmailViewController.h"
#import "ConnectionController.h"
#import "UIAlertViewBlock.h"
#import "AppDelegate.h"
#import "TargetSelectTableViewController.h"
#import "EmailComposeTableViewController.h"

@interface EmailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *dispCodeTextField;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *emailButtons;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *replyAllButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UITableView *attDataTableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIToolbar *dispCodeToolbar;
@property (strong, nonatomic) IBOutlet UIPickerView *dispCodePicker;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *ccLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UITextView *emailBodyTextView;

- (IBAction)markDone:(id)sender;
- (IBAction)deleteAction:(UIButton *)sender;
- (IBAction)addAction:(UIButton *)sender;
- (IBAction)dispCancel:(UIBarButtonItem *)sender;
- (IBAction)dispSet:(UIBarButtonItem *)sender;
- (IBAction)replyAction:(UIButton *)sender;
- (IBAction)replyAllAction:(UIButton *)sender;

@end

@implementation EmailViewController {
    // instance variables declared in implementation context
    UIAlertViewBlock *alert;
    NSArray *caseData2Show;
    BOOL editingAttachedData;
    iPadUserDataViewController *userDataVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set up the date picker as the Date text field input view
    _dispCodeTextField.inputView = _dispCodePicker;
    _dispCodeTextField.inputAccessoryView = _dispCodeToolbar;
    _dispCodeTextField.hidden = YES;
}

#pragma mark - Cometd Events

- (void)emailStatusChanged {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");
    
    //remove previous alert
    [alert dismissWithClickedButtonIndex:-1 animated:NO];
    
    if ([_ixn.state isEqualToString:@"Invited"]) {
        // Display Alert
        if (_ixn.ixnID && [_ixn.capabilities containsObject:@"Accept"]) {
            alert = [[UIAlertViewBlock alloc]
                     initWithTitle:@"Incoming Email"
                     message:[appDelegate.htccConnection.me makeToastString:_ixn]
                     completion:^(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView *av) {
                         if (cancelPressed) {
                             // Reject
                             [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                                              method:@"POST"
                                                              params:@{@"operationName": @"Reject"}
                                                                user:appDelegate.htccUser
                                                            password:appDelegate.htccPassword
                                                   completionHandler:nil];
                         }
                         else  if (buttonIndex == 1){
                             // Accept
                             [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                                              method:@"POST"
                                                              params:@{@"operationName": @"Accept"}
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
    else if ([_ixn.state isEqualToString:@"Processing"]) {
        [self updateEmailUIDisplay];
    }
    else if ([_ixn.state isEqualToString:@"Revoked"] || [_ixn.state isEqualToString:@"Completed"]) {
        [_pageVCdelegate emailMarkedDone:_ixn];
    }
}

- (void)emailUserDataChanged {
    NSAssert(_ixn.ixnID.length > 0, @"Should not be called when _ixn.ixnID.length == 0");
    
    [_attDataTableView reloadData];
    [userDataVC reloadData];
    [self updateEmailUIDisplay];
}

#pragma mark - Actions

- (IBAction)markDone:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Verify Disposition is set if it's mandatory
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-mandatory"] boolValue] && [_dispCodePicker selectedRowInComponent:0] <= 0) {
        [self displayError:@"Disposition is required"];
    }
    else if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Complete"}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
        caseData2Show = nil;
        [_attDataTableView reloadData];
    }
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
                                                         [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
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

- (IBAction)dispSet:(UIBarButtonItem *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger selRow = [_dispCodePicker selectedRowInComponent:0];
    _dispCodeTextField.text = (selRow <= 0) ? nil : appDelegate.htccConnection.me.dispCodes[selRow - 1][@"displayName"];
    [_dispCodeTextField resignFirstResponder];
    if ([appDelegate.htccConnection.me.wsSettings[@"interaction.disposition.is-read-only-on-idle"] boolValue]) {
        [self displayError:@"Disposition can be set only when email is beign composed"];
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
            [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:body
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        }
    }
}

- (IBAction)replyAction:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.wsSettings[@"email.default-queue"] &&
        [appDelegate.htccConnection.me.wsSettings[@"email.default-queue"] isKindOfClass:[NSString class]]) {
        [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"Reply", @"queueName": appDelegate.htccConnection.me.wsSettings[@"email.default-queue"]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
    else
        [self displayError:@"email.default-queue is not defined"];

}

- (IBAction)replyAllAction:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.wsSettings[@"email.default-queue"] &&
        [appDelegate.htccConnection.me.wsSettings[@"email.default-queue"] isKindOfClass:[NSString class]]) {
        [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"ReplyAll", @"queueName": appDelegate.htccConnection.me.wsSettings[@"email.default-queue"]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
    else
        [self displayError:@"email.default-queue is not defined"];
    
}

- (void)updateEmailUIDisplay
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
    _doneButton.enabled = [_ixn.capabilities containsObject:@"Complete"] ? YES : NO;
    _forwardButton.enabled = [_ixn.capabilities containsObject:@"Transfer"] ? YES : NO;
    _replyButton.enabled = [_ixn.capabilities containsObject:@"Reply"] ? YES : NO;
    _replyAllButton.enabled = [_ixn.capabilities containsObject:@"ReplyAll"] ? YES : NO;
    
    _fromLabel.text = _ixn.emailFrom;
    _toLabel.text = [_ixn.emailTo componentsJoinedByString:@", "];
    _ccLabel.text = [_ixn.emailCc componentsJoinedByString:@", "];
    _subjectLabel.text = _ixn.emailSubject;
    _emailBodyTextView.text = _ixn.emailBody;
}

- (void)displayError:(NSString *)errStr {
    self.navigationItem.prompt = errStr;
    double delayInSeconds = 10.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.prompt = nil;
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([segue.identifier isEqualToString:@"emailForwardTargetSelect"]) {
        // Perform Email Transfer
        TargetSelectTableViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = ^(NSString *dest){
            NSString *uri = [appDelegate.htccURL stringByAppendingPathComponent:@"api/v2/users"];
            uri = [uri stringByAppendingPathComponent:dest];
            [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Transfer", @"targetUri": uri}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        };
        targetVC.opsType = email;
        targetVC.navTitle = @"Email Transfer";
        targetVC.ixn = _ixn;
    }
    else if ([segue.identifier isEqualToString:@"emailUserDataPopover"]) {
        // Display User Data popover for iPad
        UIPopoverController *popVC = ((UIStoryboardPopoverSegue *)(segue)).popoverController;
        userDataVC = (iPadUserDataViewController *)popVC.contentViewController;
        userDataVC.callingVCdelegate = self;
        userDataVC.popoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
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
        [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
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

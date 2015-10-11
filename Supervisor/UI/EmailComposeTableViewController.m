//
//  EmailComposeTableViewController.m
//  HTCC Sample
//
//  Created by Arkady on 3/19/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "EmailComposeTableViewController.h"
#import "AppDelegate.h"

@interface EmailComposeTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *toCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ccBccFromCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ccCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bccCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *fromCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *subjectCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bodyCell;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UILabel *ccBccFromLabel;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextField *ccTextField;
@property (weak, nonatomic) IBOutlet UITextField *bccTextField;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UIPickerView *fromPicker;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewWidthConstraint;

- (IBAction)sendAction:(UIBarButtonItem *)sender;

@end

@implementation EmailComposeTableViewController
{
    BOOL showCcBccFromCells;
    NSArray *cellsMax, *cellsMin;
    NSArray *txtFieldsMax, *txtFieldsMin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellsMax = @[_toCell, _ccCell, _bccCell, _fromCell, _subjectCell, _bodyCell];
    cellsMin = @[_toCell, _ccBccFromCell, _subjectCell, _bodyCell];
    txtFieldsMax = @[_toTextField, _ccTextField, _bccTextField, _fromTextField, _subjectTextField, _bodyTextView];
    txtFieldsMin = @[_toTextField, _fromTextField, _subjectTextField, _bodyTextView];
    
    _fromTextField.inputView = _fromPicker;
    [[_fromTextField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    
    self.navigationItem.title = @"Email Reply";

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _ccBccFromLabel.text = appDelegate.htccConnection.me.emailFromAddresses[0][@"name"];
    _fromTextField.text = appDelegate.htccConnection.me.emailFromAddresses[0][@"name"];
    _toTextField.text = [_ixn.emailTo componentsJoinedByString:@", "];
    _ccTextField.text = [_ixn.emailCc componentsJoinedByString:@", "];
    if (_ixn.emailCc.count) {
        showCcBccFromCells = YES;
    }
    _subjectTextField.text = _ixn.emailSubject;
    
    NSString *parentReceivedDate;
    if (_ixn.emailParentID) {
        NSUInteger parentIndex = [appDelegate.htccConnection.me.emails indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [((Interaction *)obj).ixnID isEqualToString:_ixn.emailParentID];
        }];
        if (parentIndex != NSNotFound) {
            parentReceivedDate = ((Interaction *)appDelegate.htccConnection.me.emails[parentIndex]).emailReceivedDate;
        }
    }
    static NSDateFormatter *dateFormat;
    if (!dateFormat) {
        dateFormat = [[NSDateFormatter alloc] init];
    }
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSSZZZ"];
    NSDate *date = [dateFormat dateFromString:parentReceivedDate];
    [dateFormat setDateFormat:@"MMM dd, YYYY, 'at 'hh:mm a zzz"];
    
    NSString *str = [NSString stringWithFormat: @"\n\nOn %@, %@ wrote: \n\n> ", [dateFormat  stringFromDate:date], _fromTextField.text];
    if (_ixn.emailBody) {
        _bodyTextView.text = [str stringByAppendingString:[_ixn.emailBody stringByReplacingOccurrencesOfString:@"\n" withString:@"\n> "]];
    }
    
//    //Resize TextView width to enable horizontal scrolling
//    CGFloat fixedHeight = _bodyTextView.frame.size.height;
//    CGSize newSize = [_bodyTextView sizeThatFits:CGSizeMake(MAXFLOAT, fixedHeight)];
//    _scrollView.contentSize = newSize;
//    
//    CGRect newFrame = _bodyTextView.frame;
//    newFrame.size = CGSizeMake(newSize.width, fmaxf(fixedHeight, newSize.height));
//    _bodyTextView.frame = newFrame;
//    
//    CGSize sizeThatShouldFitTheContent = [_bodyTextView sizeThatFits:_bodyTextView.frame.size];
//    _textViewWidthConstraint.constant = sizeThatShouldFitTheContent.width;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (showCcBccFromCells) ? 6 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (showCcBccFromCells) ? cellsMax[indexPath.row] : cellsMin[indexPath.row];
}

- (void)reloadAll
{
    // Reload all sections
    NSIndexSet* reloadSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!showCcBccFromCells) {
        if (indexPath.row == 1) {
            showCcBccFromCells = YES;
            [self reloadAll];
        }
        [txtFieldsMin[indexPath.row] becomeFirstResponder];
    }
    else {
        if (_ccTextField.text.length == 0 && _bccTextField.text.length == 0 && (indexPath.row == 0 || indexPath.row == 4)) {
            showCcBccFromCells = NO;
            [self reloadAll];
        }
        [txtFieldsMax[indexPath.row] becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((showCcBccFromCells && indexPath.row == 5) || (!showCcBccFromCells && indexPath.row == 3)) ? 300.0 : 44.0;
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (showCcBccFromCells && _ccTextField.text.length == 0 && _bccTextField.text.length == 0 && (textField == _toTextField || textField == _subjectTextField)) {
        showCcBccFromCells = NO;
        [self reloadAll];
        [textField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (!showCcBccFromCells && textField == _toTextField)
        [_subjectTextField becomeFirstResponder];
    else if (showCcBccFromCells) {
        if (textField == _toTextField)
            [_ccTextField becomeFirstResponder];
        else if (textField == _ccTextField)
            [_bccTextField becomeFirstResponder];
        else if (textField == _bccTextField)
            [_subjectTextField becomeFirstResponder];
    }
    if (textField == _subjectTextField) {
        //Set cursor to the beginning
        [_bodyTextView becomeFirstResponder];
        _bodyTextView.selectedRange = NSMakeRange(0, 0);
    }
    return NO;
}

#pragma mark - Picker View Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.htccConnection.me.emailFromAddresses.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.htccConnection.me.emailFromAddresses[row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _fromTextField.text = appDelegate.htccConnection.me.emailFromAddresses[row][@"name"];
    _ccBccFromLabel.text = appDelegate.htccConnection.me.emailFromAddresses[row][@"name"];
}
- (IBAction)sendAction:(UIBarButtonItem *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_toTextField.text.length == 0 && _ccTextField.text.length == 0 && _bccTextField.text.length == 0) {
        [self displayError:@"Recipient(s) required"];
    }
    else {
        if (appDelegate.htccConnection.me.wsSettings[@"email.outbound-queue"] &&
            [appDelegate.htccConnection.me.wsSettings[@"email.outbound-queue"] isKindOfClass:[NSString class]]) {
            [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Send",
                                                      @"queueName": appDelegate.htccConnection.me.wsSettings[@"email.outbound-queue"],
                                                      @"email": @{@"from": _fromTextField.text,
                                                                  @"to": [_toTextField.text componentsSeparatedByString:@","],
                                                                  @"cc": [_ccTextField.text componentsSeparatedByString:@","],
                                                                  @"bcc": [_bccTextField.text componentsSeparatedByString:@","],
                                                                  @"subject": _subjectTextField.text,
                                                                  @"body": _bodyTextView.text}}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [self displayError:@"email.outbound-queue is not defined"];
    }
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.htccConnection submit2HTCC:[kEmailsURL stringByAppendingString:_ixn.ixnID]
                                     method:@"POST"
                                     params:@{@"operationName": @"Cancel"}
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayError:(NSString *)errStr {
    self.navigationItem.prompt = errStr;
    double delayInSeconds = 10.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.prompt = nil;
    });
}

@end

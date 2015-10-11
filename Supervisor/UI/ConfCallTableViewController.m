//
//  ConferenceTableViewController.m
//  HTCC Sample
//
//  Created by Arkady on 11/20/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "ConfCallTableViewController.h"
#import "AppDelegate.h"
#import "TargetSelectTableViewController.h"
#import "Contact.h"

@interface ConfCallTableViewController ()

@end

@implementation ConfCallTableViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setEditing:YES animated:YES];
}

#pragma mark Notifications

- (void)participantsChanged
{
    if (_ixn.participants.count <= 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_ixn.participants.count == 1) ? 0 : _ixn.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    static NSString *CellIdentifier = @"confParticipant";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger idx = [appDelegate.htccConnection.me.contacts indexOfObjectPassingTest:^BOOL(id contact, NSUInteger idx, BOOL *stop) {
        if ([((Contact *)contact).phoneNumber isEqualToString:_ixn.participants[indexPath.row][@"phoneNumber"]]) {
            *stop = YES;
            return TRUE;
        }
        else
            return FALSE;
    }];
    if (idx == NSNotFound)
        cell.textLabel.text = _ixn.participants[indexPath.row][@"formattedPhoneNumber"];
    else
        cell.textLabel.text = [appDelegate.htccConnection.me.contacts[idx] name];
    
    return cell;
}

#pragma mark - Table View Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove participant.
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  
    if (_ixn.ixnID) {
        [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"RemoveParticipantFromConference",
                                                  @"participant": _ixn.participants[indexPath.row][@"phoneNumber"]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    TargetSelectTableViewController *targetVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"confTargetSelect"]) {
        // Perform Single-Step conference
        targetVC.operationBlock = ^(NSString *dest){
            [appDelegate.htccConnection submit2HTCC:[kCallsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"SingleStepConference", @"destination" : @{@"phoneNumber" : dest}}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
            
        };
        targetVC.opsType = voice;
        targetVC.navigationItem.title = @"Conference";
        targetVC.ixn = _ixn;
    }
}


@end

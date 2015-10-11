//
//  ConfChatTableViewController.m
//  HTCC Sample
//
//  Created by Arkady on 12/18/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "ConfChatTableViewController.h"
#import "AppDelegate.h"
#import "TargetSelectTableViewController.h"

@interface ConfChatTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tableLabel;

@end

@implementation ConfChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayPrompt];
}

#pragma mark Notifications

- (void)participantsChanged
{
    NSInteger maxp = [[_ixn.participants valueForKey:@"nickname"] containsObject:@"system"] ? 3 : 2;
    if (_ixn.participants.count <= maxp) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.tableView reloadData];
        [self displayPrompt];
    }
}

- (void)displayPrompt {
    _tableLabel.text = @"Swipe to remove an Agent from the Conference";
    if ([[_ixn.participants valueForKey:@"visibility"] containsObject:@"Agents"]) {
        _tableLabel.text = [_tableLabel.text stringByAppendingString:@"\nTap to add Consulting Agent to the Conference"];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_ixn.participants.count == 1) ? 0 : _ixn.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    static NSString *CellIdentifier = @"confChatParticipant";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = _ixn.participants[indexPath.row][@"nickname"];
    cell.detailTextLabel.text = ([[_ixn.participants[indexPath.row][@"uri"] lastPathComponent] isEqualToString:appDelegate.htccConnection.me.myID]) ? @"Me" : _ixn.participants[indexPath.row][@"type"];
    if ([_ixn.participants[indexPath.row][@"visibility"] isKindOfClass:[NSString class]] &&
        [_ixn.participants[indexPath.row][@"visibility"] isEqualToString:@"Agents"]) {
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@" [Consult]"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_ixn.participants[indexPath.row][@"visibility"] isKindOfClass:[NSString class]] &&
        ![_ixn.participants[indexPath.row][@"visibility"] isEqualToString:@"Agents"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        //Start conf with Consulting Agent, if there is only one Consulting Agent
        if (_ixn.participants[indexPath.row][@"uri"] && [_ixn.participants[indexPath.row][@"uri"] isKindOfClass:[NSString class]]) {
            NSString *uri = [appDelegate.htccURL stringByAppendingPathComponent:@"api/v2/users"];
            uri = [uri stringByAppendingPathComponent:[[_ixn.participants[indexPath.row][@"uri"] pathComponents] lastObject]];
            [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                             method:@"POST"
                                             params:@{@"operationName": @"Invite", @"targetUri": uri}
                                               user:appDelegate.htccUser
                                           password:appDelegate.htccPassword
                                  completionHandler:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table View Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_ixn.ixnID && _ixn.participants[indexPath.row][@"uri"] && ![[_ixn.participants[indexPath.row][@"uri"] lastPathComponent] isEqualToString:appDelegate.htccConnection.me.myID]) {
        return UITableViewCellEditingStyleDelete;
    }
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove participant.
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (_ixn.ixnID && _ixn.participants[indexPath.row][@"uri"]) {
        [appDelegate.htccConnection submit2HTCC:[kChatsURL stringByAppendingString:_ixn.ixnID]
                                         method:@"POST"
                                         params:@{@"operationName": @"RemoveParticipantFromConference",
                                                  @"targetUri": _ixn.participants[indexPath.row][@"uri"]}
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    TargetSelectTableViewController *targetVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"confChatTargetSelect"]) {
        // Perform Single-Step conference
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
        targetVC.navTitle = @"Conference";
        targetVC.ixn = _ixn;
    }
}

@end

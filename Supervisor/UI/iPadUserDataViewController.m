//
//  iPadUserDataViewController.m
//  HTCC Sample
//
//  Created by Arkady on 4/1/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "iPadUserDataViewController.h"
#import "ConnectionController.h"

@interface iPadUserDataViewController ()

@property (weak, nonatomic) IBOutlet UITableView *userDataTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

- (IBAction)deleteAction:(id)sender;
- (IBAction)addAction:(id)sender;

@end

@implementation iPadUserDataViewController
{
    BOOL editingAttachedData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:kDismissPopoverPadNotification object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissPopover
{
    if ([_popoverVC isPopoverVisible]) {
        [_popoverVC dismissPopoverAnimated:NO];
    }
    _popoverVC = nil;
}

- (void)reloadData
{
    [_userDataTableView reloadData];
}

- (IBAction)deleteAction:(id)sender {
    editingAttachedData = !editingAttachedData;
    _deleteButton.title = (editingAttachedData) ? @"Done": @"Delete";
    [_userDataTableView setEditing:editingAttachedData animated:YES];
}

- (IBAction)addAction:(id)sender {
    [_callingVCdelegate setUserDataKey:nil value:nil message:@"Add"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_callingVCdelegate tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_callingVCdelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_callingVCdelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Table View Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_callingVCdelegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}


@end

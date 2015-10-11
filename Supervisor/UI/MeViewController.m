//
//  MeViewController.m
//  HTCC Sample
//
//  Created by Arkady on 10/23/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "MeViewController.h"
#import "AppDelegate.h"
#import "ConnectionController.h"
#import "MeStateSelectTableViewController.h"
#import "Device.h"
#import "Channel.h"
#import "NSArray+HTCC.h"
#import "CorePlot.h"

@interface MeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *dcTableView;
@property (weak, nonatomic) IBOutlet UITableView *statsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *DNDSwitch;
@property (weak, nonatomic) IBOutlet UIView *callsStatView;
@property (weak, nonatomic) IBOutlet UIView *durationsStatView;
@property (weak, nonatomic) IBOutlet UILabel *productivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgHandlingTimeLabel;
- (IBAction)DNDChanged:(UISwitch *)sender;

@end

@implementation MeViewController
{
    UIRefreshControl *refreshControl;
    NSArray *stats;
    CorePlot *callsPlot, *durationsPlot;
}

- (void)updateStats
{
    //Retrieve Agent States
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.htccConnection.me.myID) {
        [appDelegate.htccConnection submit2HTCC:[kStatsURL stringByAppendingString:appDelegate.htccConnection.me.myID]
                                         method:@"GET"
                                         params:nil
                                           user:appDelegate.htccUser
                                       password:appDelegate.htccPassword
                              completionHandler:^(NSDictionary *response) {
                                  if ([response[@"statistics"] isKindOfClass:[NSArray class]] &&
                                      [response[@"statistics"] areAllArrayElementsMembersOfClass:[NSDictionary class]]) {
                                      stats = response[@"statistics"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (_statsTableView) {
                                              [_statsTableView reloadData];
                                          }
                                          if (_callsStatView) {
                                              NSArray *callsStat = [stats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(statistic contains[c] %@)", @"Calls"]];
                                              callsPlot.plotData = callsStat;
                                              [callsPlot renderInView:_callsStatView animated:YES];
                                          }
                                          if (_durationsStatView) {
                                              NSArray *durationsStat = [stats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(statistic contains[c] %@)", @"Duration"]];
                                              durationsPlot.plotData = durationsStat;
                                              [durationsPlot renderInView:_durationsStatView animated:YES];
                                          }
                                          if (_productivityLabel) {
                                              NSUInteger prodIndex = [stats indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                  return [obj[@"statistic"] isEqualToString:@"Productivity"];
                                              }];
                                              if (prodIndex != NSNotFound) {
                                                  _productivityLabel.text = [NSString stringWithFormat:@"%1.1f", [stats[prodIndex][@"value"] floatValue]];
                                              }
                                          }
                                          if (_avgHandlingTimeLabel) {
                                              NSUInteger avgHTIndex = [stats indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                  return [obj[@"statistic"] isEqualToString:@"AverageHandlingTime"];
                                              }];
                                              if (avgHTIndex != NSNotFound) {
                                                  _avgHandlingTimeLabel.text = [NSString stringWithFormat:@"%1.1f", [stats[avgHTIndex][@"value"] floatValue]];
                                              }
                                          }
                                          [refreshControl endRefreshing];
                                      });
                                  }
                              }];
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || _DNDSwitch == nil /*iPad Stat*/) {
        UITableViewController *tableViewController = [[UITableViewController alloc] init];
        tableViewController.tableView = _statsTableView;
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(updateStats) forControlEvents:UIControlEventValueChanged];
        tableViewController.refreshControl = refreshControl;
    }
    if (_DNDSwitch) {
        //iPhone or iPad popover
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelsChanged) name:kUpdateDevicesChannelsNotification object:nil];
        [self updateDNDSwitch];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _DNDSwitch) {
        //iPad popover
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:kDismissPopoverPadNotification object:nil];
    }
    if (_callsStatView)
        callsPlot = [CorePlot createWithTitle:@"Calls"];
    if (_durationsStatView) {
        durationsPlot = [CorePlot createWithTitle:@"Durations"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || _DNDSwitch == nil /*iPad Stat*/) {
        [self updateStats];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark Notifications

- (void)dismissPopover
{
    if ([_devicesPopoverVC isPopoverVisible]) {
        [_devicesPopoverVC dismissPopoverAnimated:NO];
    }
    _devicesPopoverVC = nil;
}

- (void)channelsChanged
{
    [_dcTableView reloadData];
    [self updateDNDSwitch];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        double delayInSeconds = 1.;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([_devicesPopoverVC isPopoverVisible]) {
                [_devicesPopoverVC dismissPopoverAnimated:YES];
            }
            _devicesPopoverVC = nil;
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (tableView == _dcTableView) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     // Return the number of rows in the section.
    if (tableView == _dcTableView) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        return (section == 0) ? [appDelegate.htccConnection.me.devices count] : [appDelegate.htccConnection.me.channels count];
    }
    else {
        return stats.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    static NSString *DCCellIdentifier = @"channelCell";
    static NSString *StatsCellIdentifier = @"statsCell";
    UITableViewCell *cell;
    if (tableView == _dcTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:DCCellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        NSDictionary *userState;
        BOOL dndKey;
        if (indexPath.section == 0) {
            //Devices
            cell.textLabel.text = ((Device *)(appDelegate.htccConnection.me.devices[indexPath.row])).phoneNumber;
            userState = ((Device *)(appDelegate.htccConnection.me.devices[indexPath.row])).userState;
            dndKey = ((Device *)(appDelegate.htccConnection.me.devices[indexPath.row])).doNotDisturb;
        }
        else {
            //Channels
            cell.textLabel.text = [((Channel *)(appDelegate.htccConnection.me.channels[indexPath.row])).channelName capitalizedString];
            userState = ((Channel *)(appDelegate.htccConnection.me.channels[indexPath.row])).userState;
            dndKey = ((Channel *)(appDelegate.htccConnection.me.channels[indexPath.row])).doNotDisturb;
        }
        cell.detailTextLabel.text = userState[@"displayName"];
        if (dndKey)
            cell.imageView.image = [UIImage imageNamed:@"red"];
        else if ([userState[@"state"] isKindOfClass:[NSString class]]) {
            if ([userState[@"state"] isEqualToString:@"LoggedOut"])
                cell.imageView.image = [UIImage imageNamed:@"grey"];
            else if ([userState[@"state"] isEqualToString:@"NotReady"])
                cell.imageView.image = [UIImage imageNamed:@"orange"];
            else if ([userState[@"state"] isEqualToString:@"Ready"])
                cell.imageView.image = [UIImage imageNamed:@"green"];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:StatsCellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        cell.textLabel.text = stats[indexPath.row][@"statistic"];
        if ([stats[indexPath.row][@"value"] isKindOfClass:[NSNumber class]]) {
            cell.detailTextLabel.text = [stats[indexPath.row][@"value"] stringValue];
        }
    }
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MeStateSelectTableViewController *selectVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"stateSelectSegue"]) {
        selectVC.selectedDeviceIndexPath = [_dcTableView indexPathForCell:sender];
    }
    if ([segue.identifier isEqualToString:@"devicesPopoverSegue"]) {
        UINavigationController *navVC = segue.destinationViewController;
        MeViewController *meVCPopover = (MeViewController *)navVC.topViewController;
        meVCPopover.devicesPopoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
}

#pragma mark - DND

- (void) updateDNDSwitch {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Off - if one of the devices/channels is off
    BOOL dndOn = ![[appDelegate.htccConnection.me.devices valueForKey:@"doNotDisturb"] containsObject:@NO];
    dndOn &= ![[appDelegate.htccConnection.me.channels valueForKey:@"doNotDisturb"] containsObject:@NO];
    
    _DNDSwitch.on = dndOn;
}

- (IBAction)DNDChanged:(UISwitch *)sender {
    //Submit DND state change to HTCC
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.htccConnection submit2HTCC:kMeURL
                                     method:@"POST"
                                     params:@{@"operationName": (sender.on) ? @"DoNotDisturbOn" : @"DoNotDisturbOff"}
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:nil];
}

@end

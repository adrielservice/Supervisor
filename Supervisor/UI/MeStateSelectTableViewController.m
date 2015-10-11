//
//  MeStateSelectTableViewController.m
//  HTCC Sample
//
//  Created by Arkady on 10/25/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "MeStateSelectTableViewController.h"
#import "AppDelegate.h"
#import "Device.h"
#import "Channel.h"

@interface MeStateSelectTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *DNDSwitch;
- (IBAction)DNDChanged:(UISwitch *)sender;

@end

@implementation MeStateSelectTableViewController {
    // instance variables declared in implementation context
    UITableViewCell *selectedCell;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (_selectedDeviceIndexPath.section == 0) {
        //Devices
        Device *device = (Device *)appDelegate.htccConnection.me.devices[_selectedDeviceIndexPath.row];
        self.title = device.phoneNumber;
        _DNDSwitch.on = device.doNotDisturb;
    }
    else {
        //Channels
        Channel *channel = (Channel *)appDelegate.htccConnection.me.channels[_selectedDeviceIndexPath.row];
        self.title = channel.channelName;
        _DNDSwitch.on = channel.doNotDisturb;
    }
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate.htccConnection.me.agentStates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    static NSString *CellIdentifier = @"stateSelectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = appDelegate.htccConnection.me.agentStates[indexPath.row][@"displayName"];
    NSDictionary *userState = (_selectedDeviceIndexPath.section == 0) ? ((Device *)(appDelegate.htccConnection.me.devices[_selectedDeviceIndexPath.row])).userState : ((Channel *)(appDelegate.htccConnection.me.channels[_selectedDeviceIndexPath.row])).userState;

    if ([userState[@"displayName"] isKindOfClass:[NSString class]] &&
        [userState[@"displayName"] isEqualToString:appDelegate.htccConnection.me.agentStates[indexPath.row][@"displayName"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedCell = cell;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedCell = cell;
    
    //Submit device/channel state change to HTCC
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.htccConnection submit2HTCC:(_selectedDeviceIndexPath.section == 0) ? [kChannelURL stringByAppendingString:@"voice"] : [kChannelURL stringByAppendingString:((Channel *)(appDelegate.htccConnection.me.channels[_selectedDeviceIndexPath.row])).channelName]
                                     method:@"POST"
                                     params:@{@"operationName": appDelegate.htccConnection.me.agentStates[indexPath.row][@"operationName"]}
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:nil];

    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });
}


- (IBAction)DNDChanged:(UISwitch *)sender {
    
    //Submit DND state change to HTCC
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *url;
    if (_selectedDeviceIndexPath.section == 0) {
        Device *device = (Device *)appDelegate.htccConnection.me.devices[_selectedDeviceIndexPath.row];
        if (device.deviceID)
            url = [kMeDevicesURL stringByAppendingString:device.deviceID];
    }
    else {
        Channel *channel = (Channel *)appDelegate.htccConnection.me.channels[_selectedDeviceIndexPath.row];
        if (channel.channelName)
            url = [kChannelURL stringByAppendingString:channel.channelName];
    }
    [appDelegate.htccConnection submit2HTCC:url
                                     method:@"POST"
                                     params:@{@"operationName": (sender.on) ? @"DoNotDisturbOn" : @"DoNotDisturbOff"}
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:nil];
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });
}
@end

//
//  TargetSelectTableViewController.m
//  HTCC Sample
//
//  Created by Arkady on 11/9/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "TargetSelectTableViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "DTMFViewController.h"

@interface TargetSelectTableViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *dtmfButton;

@end

@implementation TargetSelectTableViewController
{
    // instance variables declared in implementation context
    NSMutableArray *sectionsArray;
    UILocalizedIndexedCollation *collation;
    // the searchResults array contains the content filtered as a result of a search
    NSMutableArray *searchResults;
    BOOL historyOn;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = _navTitle;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(retrieveContacts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Set the return key and keyboard appearance of the search bar
    for (UIView *subView in [_searchBar subviews]) {
        for(UIView *subSubView in [subView subviews]) {
            if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                [(UITextField *)subSubView setReturnKeyType: UIReturnKeyGo];
            }
        }
    }
    _dtmfButton.hidden = (_opsType == voice) ? NO : YES;
    [self retrieveContacts];
}

#pragma mark - Set the data array and configure the section data

- (void)configureSections {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
	// Get the current collation and keep a reference to it.
	collation = [UILocalizedIndexedCollation currentCollation];
    
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
    
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the Targets for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
    
    // Segregate the Targets into the appropriate arrays.
	for (Contact *target in appDelegate.htccConnection.me.contacts) {
        
		// Ask the collation which section number the Target belongs in, based on its name.
		NSInteger sectionNumber = [collation sectionForObject:target collationStringSelector:@selector(name)];
        
		// Get the array for the section.
		NSMutableArray *sectionTargets = newSectionsArray[sectionNumber];
        
		//  Add the time zone to the section.
		[sectionTargets addObject:target];
	}

    // Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
        
		NSMutableArray *sectionTargets = newSectionsArray[index];
		NSArray *sortedTargetsArrayForSection = [collation sortedArrayFromArray:sectionTargets collationStringSelector:@selector(name)];
        
		// Replace the existing array with the sorted array.
		newSectionsArray[index] = sortedTargetsArrayForSection;
	}
    
	sectionsArray = newSectionsArray;
}

- (BOOL)contactChatConsultOn:(NSString *)targetID {
    //returns TRUE if target is in Chat Consultation
    BOOL __block consultOn = FALSE;
    [_ixn.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"uri"] isKindOfClass:[NSString class]] && [[[obj[@"uri"] pathComponents] lastObject] isEqualToString:targetID] &&
            [obj[@"visibility"] isKindOfClass:[NSString class]] && [obj[@"visibility"] isEqualToString:@"Agents"]) {
            *stop = YES;
            consultOn = TRUE;
        }
    }];
    return consultOn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // If the requesting table view is the search display controller's table view,
    // return the count of the filtered list, otherwise return the count of the main list
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    else {
        // The number of sections is the same as the number of titles in the collation.
        return (historyOn) ? 1 : [[collation sectionTitles] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else {
        // The number of Targets in the section is the count of the array associated with the section in the sections array.
        return (historyOn) ? [appDelegate.htccConnection.me.history count] : [sectionsArray[section] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    static NSString *CellIdentifier = @"targetSelectCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	// Get the Target from the array associated with the section index in the sections array.
	Contact *target;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        target = searchResults[indexPath.row];
    }
    else {
        target = (historyOn) ? appDelegate.htccConnection.me.history[indexPath.row] : sectionsArray[indexPath.section][indexPath.row];
    }
    
	// Configure the cell with the Target's name and presence
    if (_opsType == chat && [self contactChatConsultOn:target.hID]) {
        cell.textLabel.text = [target.name stringByAppendingString:@" [Consult]"];
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else
        cell.textLabel.text = target.name;
    cell.detailTextLabel.text = target.phoneNumber;
    if ([target.targetType isEqualToString:@"User"]) {
        cell.imageView.image = [UIImage imageNamed:@"agent"];
    }
    else if ([target.targetType isEqualToString:@"Queue"]) {
        cell.imageView.image = [UIImage imageNamed:@"queue"];
    }
    else if ([target.targetType isEqualToString:@"Custom"]) {
        cell.imageView.image = [UIImage imageNamed:@"custom"];
    }
    cell.accessoryView = nil;
    if (!historyOn) {
        if ((_opsType == voice && [target.presence[@"voice"] boolValue]) ||
            (_opsType == chat && [target.presence[@"chat"] boolValue]) ||
            (_opsType == email && [target.presence[@"email"] boolValue]))
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green"]];
    }
    else {
        // Look for presence state in latest downloaded data, history presence might be old
        [appDelegate.htccConnection.me.contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Contact *t = (Contact *)obj;
            if ([t.hID isEqualToString:target.hID]) {
                if ((_opsType == voice && [t.presence[@"voice"] boolValue]) ||
                    (_opsType == chat && [t.presence[@"chat"] boolValue]) ||
                    (_opsType == email && [target.presence[@"email"] boolValue]))
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green"]];
                *stop = YES;
            }
        }];
    }
    return cell;
}


// Section-related methods: Retrieve the section titles and section index titles from the collation.


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView || historyOn) {
        return nil;
    }
    else {
        if ([sectionsArray[section] count] > 0) {
            return [collation sectionTitles][section];
        }
        return nil;
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView || historyOn) {
        return nil;
    }
    else {
        return [collation sectionIndexTitles];
    }
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView || historyOn) {
        return -1;
    }
    else {
        return [collation sectionForSectionIndexTitleAtIndex:index];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    Contact *target;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        target = searchResults[indexPath.row];
    }
    else {
        target = (historyOn) ? appDelegate.htccConnection.me.history[indexPath.row] : sectionsArray[indexPath.section][indexPath.row];
    }
    
    if (![appDelegate.htccConnection.me.history containsObject:target]) {
        [appDelegate.htccConnection.me.history addObject:target];
    }
    
    [self performOps:(_opsType == voice) ? target.phoneNumber : target.hID];
 }

#pragma mark - Content Filtering

- (void)updateFilteredContentForTargetName:(NSString *)targetName type:(NSString *)typeName
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    [searchResults removeAllObjects]; // First clear the filtered array.

	// Search the main list for targets whose type matches the scope (if selected) and whose name or phone number matches searchText;
    // add items that match to the filtered array.
    for (Contact *target in (historyOn) ? appDelegate.htccConnection.me.history : appDelegate.htccConnection.me.contacts) {
		if ([target.targetType isEqualToString:typeName] || [typeName isEqualToString:@"All"]) {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange foundRangeName = [target.name rangeOfString:targetName options:searchOptions range:NSMakeRange(0, target.name.length)];
            NSRange foundRangeNumber = [target.phoneNumber rangeOfString:targetName options:searchOptions range:NSMakeRange(0, target.phoneNumber.length)];
            if (foundRangeName.length > 0 || foundRangeNumber.length > 0) {
				[searchResults addObject:target];
            }
		}
	}
   [searchResults sortUsingComparator:^NSComparisonResult(id a, id b) {
        return [((Contact *)a).name compare:((Contact *)b).name];
    }];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForTargetName:searchString type:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self updateFilteredContentForTargetName:[self.searchDisplayController.searchBar text] type:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length > 0) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        Contact *newContact = [Contact createContact:@{@"phoneNumber": searchBar.text, @"targetType": @"Custom"}];
        if (![[appDelegate.htccConnection.me.history valueForKey:@"phoneNumber"] containsObject:newContact.phoneNumber]) {
            [appDelegate.htccConnection.me.history addObject:newContact];
        }
        [self performOps:searchBar.text];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    historyOn = !historyOn;
    self.navigationItem.title = (historyOn) ? @"History" : _navTitle;
    [self.tableView reloadData];
}

#pragma mark Actions

- (void)retrieveContacts
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Retrieve Contacts
    [appDelegate.htccConnection submit2HTCC:kContactsURL
                                     method:@"GET"
                                     params:nil
                                       user:appDelegate.htccUser
                                   password:appDelegate.htccPassword
                          completionHandler:^(NSDictionary *response) {
                              if ([response isKindOfClass:[NSDictionary class]]) {
                                  if ([response[@"contacts"] isKindOfClass:[NSArray class]]) {
                                      NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[response[@"contacts"] count]];
                                      for (NSDictionary *sk in response[@"contacts"]) {
                                          if ([sk[@"id"] isKindOfClass:[NSString class]] && ![sk[@"id"] isEqualToString:appDelegate.htccConnection.me.myID]) {
                                              //Do not add ourself
                                              [arr addObject:[Contact createContact:sk]];
                                          }
                                      }
                                      appDelegate.htccConnection.me.contacts = arr;
                                      
                                      [self configureSections];
                                      
                                      // create a filtered list that will contain targets for the search results table.
                                      if (searchResults == nil) {
                                          searchResults = [NSMutableArray arrayWithCapacity:[appDelegate.htccConnection.me.contacts count]];
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.refreshControl endRefreshing];
                                          [self.tableView reloadData];
                                      });
                                  }
                              }
                          }];
}

- (void)performOps:(NSString *)phone
{
    // Strip extra characters
    NSString *stripped = [phone stringByReplacingOccurrencesOfString:@"[^0-9a-zA-Z,+]"
                                                          withString:@""
                                                             options:NSRegularExpressionSearch
                                                               range:NSMakeRange(0, [phone length])];
    // Perform Operation
    if (_operationBlock && stripped) {
        _operationBlock(stripped);
    }
    
    [self.searchDisplayController setActive:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"dialNumber"]) {
        DTMFViewController *targetVC = segue.destinationViewController;
        targetVC.operationBlock = _operationBlock;
        targetVC.sendDTMF = FALSE;
    }
    if ([segue.identifier isEqualToString:@"dialNumberPopover"]) {
        //iPad
        UINavigationController *navVC = segue.destinationViewController;
        DTMFViewController *targetVC = (DTMFViewController *)navVC.topViewController;
        targetVC.popoverVC = ((UIStoryboardPopoverSegue *)segue).popoverController;
        targetVC.operationBlock = _operationBlock;
        targetVC.sendDTMF = FALSE;
    }
}

@end

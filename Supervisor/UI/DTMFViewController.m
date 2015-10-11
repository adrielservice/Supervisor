//
//  DialViewController.m
//  HTCC Sample
//
//  Created by Arkady on 11/25/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//

#import "DTMFViewController.h"
#import "AppDelegate.h"
#import "SoundEffect.h"
#import "RMPhoneFormat.h"
#import "Contact.h"

@interface DTMFViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dialButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;


- (IBAction)buttonSelected:(UIButton *)sender;
- (IBAction)dialAction:(UIBarButtonItem *)sender;
- (IBAction)deleteDigit:(UIButton *)sender;
- (IBAction)plusPressed:(UILongPressGestureRecognizer *)sender;

@end

@implementation DTMFViewController {
    // instance variables declared in implementation context
    NSMutableArray *tonesArray;
    NSArray *symbolsArray;
    RMPhoneFormat *fmt;
}


#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textLabel.text = @"";
 
    NSBundle *mainBundle = [NSBundle mainBundle];
    tonesArray = [[NSMutableArray alloc] init];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"0" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"1" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"2" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"3" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"4" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"5" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"6" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"7" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"8" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"9" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"star" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"numeral" ofType:@"wav"]]];
    [tonesArray addObject:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Plus" ofType:@"wav"]]];
    
    symbolsArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", @"#", @"+"];
    
    // Play a brief sound of silence to get the lazy initialization out of the way (otherwise the first sound played is delayed by 1/2 second
    
    [[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"silence" ofType:@"caf"]] play];
    
    self.navigationItem.rightBarButtonItem = (_sendDTMF) ? nil : _dialButton;
    _deleteButton.hidden = YES;
    _dialButton.enabled = NO;
    
    fmt = [RMPhoneFormat instance];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        self.preferredContentSize = CGSizeMake(320., 440.);
}

- (IBAction)buttonSelected:(UIButton *)sender {
    
    if (sender.tag >=0 && sender.tag < tonesArray.count) {
        [tonesArray[sender.tag] play];
        
        _textLabel.text = [_textLabel.text stringByAppendingString:symbolsArray[sender.tag]];
        
        if (_sendDTMF && _operationBlock) {
            _operationBlock(symbolsArray[sender.tag]);
        }
        else {
            _textLabel.text = [fmt format:_textLabel.text];
            [self updateDeleteDialButtons];
        }

    }
}

- (IBAction)dialAction:(UIBarButtonItem *)sender {
    // Strip extra characters
    NSString *stripped = [_textLabel.text stringByReplacingOccurrencesOfString:@"[^0-9a-zA-Z,+#*]"
                                                          withString:@""
                                                             options:NSRegularExpressionSearch
                                                               range:NSMakeRange(0, [_textLabel.text length])];
    
    // Perform Operation
    if (_operationBlock && stripped) {
        _operationBlock(stripped);
    }
    
    
    // Save in history
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    Contact *newContact = [Contact createContact:@{@"phoneNumber": stripped, @"targetType": @"Custom"}];
    if (![appDelegate.htccConnection.me.history containsObject:newContact]) {
        [appDelegate.htccConnection.me.history addObject:newContact];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [_popoverVC isPopoverVisible])
        [_popoverVC dismissPopoverAnimated:YES];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateDeleteDialButtons {
    _deleteButton.hidden = (_textLabel.text.length) ? NO : YES;
    _dialButton.enabled = (_textLabel.text.length) ? YES : NO;
}

- (IBAction)deleteDigit:(UIButton *)sender {
    if ([_textLabel.text length] > 0) {
        NSString *stripped = [_textLabel.text stringByReplacingOccurrencesOfString:@"[^0-9a-zA-Z,+#*]"
                                                                        withString:@""
                                                                           options:NSRegularExpressionSearch
                                                                             range:NSMakeRange(0, [_textLabel.text length])];
        stripped = [stripped substringToIndex:stripped.length - 1];
        _textLabel.text = [fmt format:stripped];
        [self updateDeleteDialButtons];
    }
}

- (IBAction)plusPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    [self buttonSelected:_plusButton];
}

@end

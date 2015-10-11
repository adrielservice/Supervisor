//
//  LogViewController.m
//  HTCC Sample
//
/*
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This software is supplied to you by Genesys
 Telecommunications Laboratories Inc ("Genesys") in consideration of your agreement
 to the following terms, and your use, installation, modification or redistribution
 of this Genesys software constitutes acceptance of these terms.  If you do not
 agree with these terms, please do not use, install, modify or redistribute this
 Genesys software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Genesys grants you a personal, non-exclusive license, under
 Genesys's copyrights in this original Genesys software (the "Genesys Software"), to
 use, reproduce, modify and redistribute the Genesys Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Genesys Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Genesys Software.
 
 Neither the name, trademarks, service marks or logos of Genesys Inc. may be used
 to endorse or promote products derived from the Genesys Software without specific
 prior written permission from Genesys.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Genesys herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Genesys Software may be
 incorporated.
 
 The Genesys Software is provided by Genesys on an "AS IS" basis.  GENESYS MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE GENESYS SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL GENESYS BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE GENESYS SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 GENESYS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Genesys Inc. All Rights Reserved.
 */


#import "LogViewController.h"
#import "ConnectionController.h"

@interface LogViewController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)clearLog:(id)sender;

@end

@implementation LogViewController
{
    // instance variables declared in implementation context
    NSString *displayHTML;
}

//Register for notification (for Web view updates) when view is loaded from storyboard
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        displayHTML = @"";
        //Add this as an observer for push notifications from HTCC
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHTML:) name:kUpdateLogNotification object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark View LifeCycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_webView loadHTMLString:displayHTML baseURL:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setWebView:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Observer update
- (void) updateHTML:(NSNotification *)notificaton {
    
    if (notificaton.userInfo[@"text"]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MMM-YYYY HH:mm:ss z"];
        NSString *currTime = [dateFormat stringFromDate:[NSDate date]];
        
        if ([notificaton.userInfo[@"direction"] integerValue] == toHTCC) {
            displayHTML = [displayHTML stringByAppendingFormat:@"<p><font color=\"darkgrey\"><u><b>---> To HTCC: %@</b></u><br>", currTime];
            
        }
        else {
            displayHTML = [displayHTML stringByAppendingFormat:@"<p><font color=\"black\"><u><b><--- From HTCC: %@</b></u><br>", currTime];
        }
        //replace \n with <br>
        NSString *addedBRString = [notificaton.userInfo[@"text"] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        displayHTML = [displayHTML stringByAppendingFormat:@"%@</font></p><hr>", addedBRString];
    }
}

#pragma mark -
#pragma mark Web View delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //Scroll to the bottom
    [webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0, document.body.scrollHeight);"];
}

#pragma mark -
#pragma mark Clear Log Action

- (IBAction)clearLog:(id)sender {
    displayHTML = @"";
    [_webView loadHTMLString:displayHTML baseURL:nil];
}

@end

//
//  UIAlertViewBlock.m
//  GMS Sample
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

#import "UIAlertViewBlock.h"


@interface UIAlertViewBlock ()
@property (copy, nonatomic) void (^completion)(BOOL, NSInteger, UIAlertView *);
@end

@implementation UIAlertViewBlock


- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         completion:(void (^)(BOOL cancelPressed, NSInteger buttonIndex, UIAlertView * alertView))completion
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil ];
    
    if (self) {
        self.completion = completion;
        
        va_list _arguments;
        va_start(_arguments, otherButtonTitles);
        
        for (NSString *key = otherButtonTitles; key != nil; key = (__bridge NSString *)va_arg(_arguments, void *)) {
            [self addButtonWithTitle:key];
        }
        va_end(_arguments);
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (self.completion) {
        self.completion(buttonIndex==self.cancelButtonIndex, buttonIndex, self);
    }
}

- (void) dismissExisting:(NSArray *)subviews {
    Class AVClass = [UIAlertView class];
    for (UIView * subview in subviews){
        if ([subview isKindOfClass:AVClass]){
            [(UIAlertView *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
        } else {
            [self dismissExisting:subview.subviews];
        }
    }
}

- (void)show {
        
    if (_dismissTimeout > 0. && self.alertViewStyle == UIAlertViewStyleDefault) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _dismissTimeout * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissWithClickedButtonIndex:0 animated:NO];
        });
    }
    
    //Dismiss existing alert
    [self dismissExisting:[UIApplication sharedApplication].windows];
    [super show];
}

@end

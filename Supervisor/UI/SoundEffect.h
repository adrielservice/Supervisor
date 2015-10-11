//
//  SoundEffect.h
//  Keypad
//
//  Created by Arkady on 10/23/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffect : NSObject 

- (id)initWithContentsOfFile:(NSString *)path;
- (void)play;

@end

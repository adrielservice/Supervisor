//
//  SoundEffect.m
//  Keypad
//
//  Created by Arkady on 10/23/13.
//  Copyright (c) 2013 Genesys. All rights reserved.
//


#import "SoundEffect.h"

@implementation SoundEffect
{
    // instance variables declared in implementation context
    SystemSoundID _soundID;
}

- (id)initWithContentsOfFile:(NSString *)path 
{
    if ((self = [super init]) != nil)
    {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (aFileURL)  {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL, &aSoundID);
            
            if (error == kAudioServicesNoError) { // success
                _soundID = aSoundID;
            } 
            else  {
                NSLog(@"Error (%d) loading sound at path: %@", (int)error, path);
                self = nil;
            }
        } 
        else  {
            NSLog(@"NSURL is nil for path: %@", path);
            self = nil;
        }
    }
    return self;
}

-(void)dealloc 
{
    AudioServicesDisposeSystemSoundID(_soundID);
}

-(void)play 
{
    AudioServicesPlaySystemSound(_soundID);
}

@end

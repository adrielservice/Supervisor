//
//  GSStatistics.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/01/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GSAudioStreamStatistics.h"

@interface GSStatistics : NSObject {
    NSString* codecName;

    int gotLocalStat;
    float localFractionLost;
    int localTotalLost;
    unsigned localJitter;
    unsigned localPktCount;
    unsigned localOctCount;
    
    int gotRemoteSR;
    unsigned remotePktCount;
    unsigned remoteOctCount;
    
    int gotRemoteRR;
    float remoteFractionLost;
    int remoteTotalLost;
    unsigned remoteJitter;
    int rttMs;
}

@property (nonatomic, copy) NSString* codecName;

@property (nonatomic) int gotLocalStat;
@property (nonatomic) float localFractionLost;
@property (nonatomic) int localTotalLost;
@property (nonatomic) unsigned localJitter;
@property (nonatomic) unsigned localPktCount;
@property (nonatomic) unsigned localOctCount;

@property (nonatomic) int gotRemoteSR;
@property (nonatomic) unsigned remotePktCount;
@property (nonatomic) unsigned remoteOctCount;

@property (nonatomic) int gotRemoteRR;
@property (nonatomic) float remoteFractionLost;
@property (nonatomic) int remoteTotalLost;
@property (nonatomic) unsigned remoteJitter;
@property (nonatomic) int rttMs;

@end

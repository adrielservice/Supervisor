//
//  GSDefaultLogger.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GSLogger.h"

/**
 A default implementation of the GSLogger protocol. This class uses "NSLog" to log all messages.
 
 @see GSLogger
 */
@interface GSDefaultLogger : NSObject <GSLogger> {
@private
    NSString* name;
    NSString* logFile;
    NSString* logLevel;
    bool isDebugLevel;
    bool isInfoLevel;
    bool isWarningLevel;
    bool isErrorLevel;
    bool isFatalErrorLevel;
}

/**
 The name of this logger instance.
 */
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* logFile;
@property (nonatomic, copy) NSString* logLevel;

@property (nonatomic) bool isDebugLevel;
@property (nonatomic) bool isInfoLevel;
@property (nonatomic) bool isWarningLevel;
@property (nonatomic) bool isErrorLevel;
@property (nonatomic) bool isFatalErrorLevel;


/**
 Initializes an instances of the logger with the specified name.
 @param name the name for this logger instance
 @returns an instance of the logger or nil if the initialization is not successful.
 */
- (id)initWithName:(NSString*) name;

/**
 Initializes an instances of the logger with the specified name.
 @param name the name for this logger instance
 @param logLevel the value of log level: debug; info; warn; error; fatal
 @returns an instance of the logger or nil if the initialization is not successful.
 */
- (id)initWithName:(NSString*) name logLevel:(NSString*) logLevel;

/**
 Initializes an instances of the logger with the specified name and logfile.
 @param name the name for this logger instance
 @param file the log file name and path
 @param logLevel the value of the log level: debug; info; warn; error; fatal
 @returns an instance of the logger or nil if the initialization is not successful.
 */
- (id)initWithName:(NSString*) name logFile:(NSString*) file logLevel:(NSString*) logLevel;

/**
 Assign properties: isDebugLevel, isInfoLevel, isWarningLevel, isErrorLevel, isFatalErrorLevel
 to YES or NO depends on logLevel
 @param logLevel the value of log level: debug; info; warn; error; fatal
 */
- (BOOL)setupEnabledLogLevels:(NSString*) logLevel;

@end

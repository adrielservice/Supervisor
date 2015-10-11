//
//  GSLogger.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//



#import <Foundation/Foundation.h>

/**
 This protocol should be used to implement a logger object to be used by the SipEndpoint framework. 
 */
@protocol GSLogger <NSObject>


/**
 @returns a Log Level
 */

-(NSString*) getLogLevel;

/**
 Creates a child logger with the specified name.
 
 @param the child logger's name
 @returns the child logger instance
 */
-(id<GSLogger>) createChildLogger:(NSString*) loggerName;

/**
 Creates a child logger with the specified name.
 
 @param the child logger's name
 @param the child logger's log level
 @returns the child logger instance
 */
-(id<GSLogger>) createChildLogger:(NSString*) loggerName logLevel:(NSString*) logLevel;

/**
 Logs the specified message with 'debug' priority.
 
 @param message the message
 */
-(void) logDebugMessage:(NSString*) message;

/**
 Logs the specified message with 'debug' priority. 
 
 @param format message format
 @param ... a comma separated list of arguments to be inserted into format
 */
-(void) logDebugMessageWithFormat:(NSString*) format, ...;

/**
 Logs the specified message with 'info' priority.
 
 @param message the message
 */
-(void) logInfoMessage:(NSString*) message;

/**
 Logs the specified message with 'info' priority. 
 
 @param format message format
 @param ... a comma separated list of arguments to be inserted into format
 */
-(void) logInfoMessageWithFormat:(NSString*) format, ...;

/**
 Logs the specified message with 'warning' priority.
 
 @param message the message
 */
-(void) logWarningMessage:(NSString*) message;

/**
 Logs the specified message with 'warning' priority. 
 
 @param format message format
 @param ... a comma separated list of arguments to be inserted into format
 */
-(void) logWarningMessageWithFormat:(NSString*) format, ...;

/**
 Logs the specified message with 'error' priority.
 
 @param message the message
 */
-(void) logErrorMessage:(NSString*) message;

/**
 Logs the specified message with 'error' priority. 
 
 @param format message format
 @param ... a comma separated list of arguments to be inserted into format
 */
-(void) logErrorMessageWithFormat:(NSString*) format, ...;

/**
 Logs the specified message with 'fatal error' priority.
 
 @param message the message
 */
-(void) logFatalErrorMessage:(NSString*) message;

/**
 Logs the specified message with 'fatal error' priority. 
 
 @param format message format
 @param ... a comma separated list of arguments to be inserted into format
 */
-(void) logFatalErrorMessageWithFormat:(NSString*) format, ...;

/**
 @returns YES if debug priority logging is enabled, NO otherwise
 */
-(bool) isDebugEnabled;

/**
 @returns YES if info priority logging is enabled, NO otherwise
 */
-(bool) isInfoEnabled;

/**
 @returns YES if warning priority logging is enabled, NO otherwise
 */
-(bool) isWarningEnabled;

/**
 @returns YES if error priority logging is enabled, NO otherwise
 */
-(bool) isErrorEnabled;

/**
 @returns YES if fatal error priority logging is enabled, NO otherwise
 */
-(bool) isFatalErrorEnabled;

@end

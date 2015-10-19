
#import <Foundation/Foundation.h>
#import "xCSRF.h"

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#	define DDCometDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DDCometDLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define DDCometALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@class DDCometLongPollingTransport;
@class DDCometMessage;
@class DDCometSubscription;
@class DDQueueProcessor;
@protocol DDCometClientDelegate;
@protocol DDQueue;

typedef enum
{
	DDCometStateDisconnected,
    DDCometStateHandshaking,
	DDCometStateConnecting,
	DDCometStateConnected,
	DDCometStateDisconnecting,
    DDCometStateTransportError
} DDCometState;

@protocol DDCometClientSubscriptionDelegate;
@protocol DDCometClientDataDelegate;

@interface DDCometClient : NSObject
{
@private
	NSURL *m_endpointURL;
	volatile int32_t m_messageCounter;
	NSMutableDictionary *m_pendingSubscriptions; // by id to NSArray
	NSMutableArray *m_subscriptions;
	DDCometState m_state;
	NSDictionary *m_advice;
	id<DDQueue> m_outgoingQueue;
	id<DDQueue> m_incomingQueue;
	DDCometLongPollingTransport *m_transport;
	DDQueueProcessor *m_incomingProcessor;
    NSDictionary *m_handshakeExtData;
    BOOL m_allowDuplicateSubscriptions;
    BOOL m_reconnectOnClientExpired;
    BOOL m_persistentSubscriptions;
}

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSURL *endpointURL;
@property (nonatomic, readonly) DDCometState state;
@property (nonatomic, readonly) NSDictionary *advice;
@property (nonatomic, readonly) NSString *gmsUserHeader;
@property (nonatomic, retain) xCSRF *csrf;
@property (nonatomic, weak) id<DDCometClientDelegate> delegate;
@property (nonatomic, assign) BOOL allowDuplicateSubscriptions;

//Should we reconnect automatically and create a new client session if the session we were using expired
//    If YES and on a "/meta/connect" request the server returns error 402, then [self handshake] will immediately be called
@property (nonatomic, assign) BOOL reconnectOnClientExpired; // Default is NO
//If the client is disconnected (because the server session expired, 'disconnect' was called or because of a transport error)
//     should subscriptions be maintained so that they are resubscribed once the client reconnects?
//     If set to NO, all subscriptions will need to be resubscribed when any disconnection occurs
//     If set to YES (default) and you would need to call 'unsubscribeAll' after calling 'disconnect' if you don't want subscriptions to resubscribe automatically when 'handshake' is called
@property (nonatomic, assign) BOOL persistentSubscriptions; // Default to NO

- (id)initWithURL:(NSURL *)endpointURL;
- (id)initWithURL:(NSURL *)endpointURL gmsHeader:(NSString *)gmsUH;
- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (DDCometMessage *)handshake;
- (DDCometMessage *)handshakeWithExtData:(NSDictionary*)extData;
- (DDCometMessage *)disconnect;
- (DDCometMessage *)disconnectSynchronous;
- (DDCometMessage *)disconnectSynchronousWithExt:(NSDictionary*)ext;
- (DDCometSubscription *)subscribeToChannel:(NSString *)channel target:(id)target selector:(SEL)selector;
- (DDCometSubscription *)subscribeToChannel:(NSString *)channel target:(id)target selector:(SEL)selector delegate:(id<DDCometClientSubscriptionDelegate>)delegate;
- (DDCometSubscription *)subscribeToChannel:(NSString *)channel target:(id)target selector:(SEL)selector successBlock:(void(^)(DDCometClient*,DDCometSubscription*))successBlock errorBlock:(void(^)(DDCometClient*,DDCometSubscription*,NSError*))errorBlock;
- (DDCometMessage *)unsubsubscribeFromChannel:(NSString *)channel target:(id)target selector:(SEL)selector;
- (void)unsubscribeWithSubscription:(DDCometSubscription*)subscription;
- (DDCometMessage *)publishData:(id)data toChannel:(NSString *)channel;
- (DDCometMessage *)publishData:(id)data toChannel:(NSString *)channel withDelegate:(id<DDCometClientDataDelegate>)delegate;
- (DDCometMessage *)publishData:(id)data toChannel:(NSString *)channel
                   successBlock:(void(^)(DDCometClient*,id,NSString*))successBlock
                     errorBlock:(void(^)(DDCometClient*,id,NSString*,NSError*))errorBlock;
- (void) unsubscribeAll;

@end

@interface DDCometClient (Internal)  //Should not be accessed externally

- (id<DDQueue>)outgoingQueue;
- (id<DDQueue>)incomingQueue;
- (void) connectionFailed:(NSURLConnection*)connection withError:(NSError*)error withMessages:(NSArray*)messages;
- (void) messagesDidSend:(NSArray*)messages;
- (id<DDCometClientDataDelegate>)delegateForMessage:(DDCometMessage*)message;
- (void)handleMessage:(DDCometMessage *)message;
@end

@protocol DDCometClientSubscriptionDelegate <NSObject>
@optional
- (void)cometClient:(DDCometClient *)client subscriptionDidSucceed:(DDCometSubscription *)subscription;
- (void)cometClient:(DDCometClient *)client subscription:(DDCometSubscription *)subscription didFailWithError:(NSError *)error;
@end

@protocol DDCometClientDataDelegate <NSObject>
@optional
- (void)cometClient:(DDCometClient*)client dataDidSend:(id)data toChannel:(NSString*)channel;
- (void)cometClient:(DDCometClient*)client data:(id)data toChannel:(NSString*)channel didFailWithError:(NSError*)error;
@end

@protocol DDCometClientDelegate <DDCometClientSubscriptionDelegate, DDCometClientDataDelegate>
@optional
- (void)cometClientHandshakeDidSucceed:(DDCometClient *)client;
- (void)cometClient:(DDCometClient *)client handshakeDidFailWithError:(NSError *)error;
- (void)cometClientConnectDidSucceed:(DDCometClient *)client;
- (void)cometClient:(DDCometClient *)client connectDidFailWithError:(NSError *)error;
- (void)cometClient:(DDCometClient*)client stoppedReceivingMessagesWithError:(NSError*)error;
- (void)cometClientContinuedReceivingMessages:(DDCometClient*)client;
- (void)cometClient:(DDCometClient*)client didFailWithTransportError:(NSError*)error;
- (void)cometClientExpired:(DDCometClient*)client;
@end

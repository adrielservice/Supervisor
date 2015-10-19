
#import <Foundation/Foundation.h>


@class DDCometClient, DDCometMessage;

@interface DDCometLongPollingTransport : NSObject
{
@private
    DDCometClient *m_client;
    volatile BOOL m_shouldCancel;
}

- (id)initWithClient:(DDCometClient *)client;
- (void)start;
- (void)cancel;
- (NSDictionary *)sendSynchronous:(DDCometMessage *)message;

@end

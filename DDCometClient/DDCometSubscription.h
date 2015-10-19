
#import <Foundation/Foundation.h>
#import "DDCometClient.h"


@interface DDCometSubscription : NSObject

@property (nonatomic, readonly) NSString *channel;
@property (weak, nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL selector;
@property (weak, nonatomic, readonly) id<DDCometClientSubscriptionDelegate> delegate;
@property (nonatomic, readonly, getter=isWildcard) BOOL wildcard;

- (id)initWithChannel:(NSString *)channel target:(id)target selector:(SEL)selector;
- (id)initWithChannel:(NSString *)channel target:(id)target selector:(SEL)selector delegate:(id<DDCometClientSubscriptionDelegate>)delegate;
- (BOOL)matchesChannel:(NSString *)channel;
- (BOOL)isParentChannel:(NSString*)channel;

+(BOOL)channel:(NSString*)parent isParentTo:(NSString*)channel;
+(BOOL)channel:(NSString*)subchannel matchesChannel:(NSString*)parent;

@end

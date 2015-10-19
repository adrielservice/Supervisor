
#import "DDCometSubscription.h"


@implementation DDCometSubscription

@synthesize channel = m_channel,
	target = m_target,
	selector = m_selector,
    delegate = m_delegate;

- (id)initWithChannel:(NSString *)channel target:(id)target selector:(SEL)selector
{
	if ((self = [super init]))
	{
		m_channel = channel;
		m_target = target;
		m_selector = selector;
	}
	return self;
}

- (id)initWithChannel:(NSString *)channel target:(id)target selector:(SEL)selector delegate:(id<DDCometClientDelegate>)delegate
{
	if ((self = [self initWithChannel:channel target:target selector:selector]))
	{
        m_delegate = delegate;
	}
	return self;
}


- (BOOL)matchesChannel:(NSString *)channel
{
	if ([m_channel isEqualToString:channel])
		return YES;
	if ([m_channel hasSuffix:@"/**"])
	{
		NSString *prefix = [m_channel substringToIndex:([m_channel length] - 2)];
        return [channel hasPrefix:prefix];
	}
	else if ([m_channel hasSuffix:@"/*"])
	{
		NSString *prefix = [m_channel substringToIndex:([m_channel length] - 1)];
		if ([channel hasPrefix:prefix] && [[channel substringFromIndex:([m_channel length] - 1)] rangeOfString:@"*"].location == NSNotFound)
			return YES;
	}
	return NO;
}

-(BOOL)isWildcard
{
    return [m_channel hasSuffix:@"/*"] || [m_channel hasSuffix:@"/**"];
}

-(BOOL)isParentChannel:(NSString*)channel
{
    if ([channel hasSuffix:@"/*"]) {
        NSString *prefix = [channel substringToIndex:([channel length] - 1)];
        return [m_channel hasPrefix:prefix] && [[m_channel substringFromIndex:([m_channel length] - 1)] rangeOfString:@"*"].location == NSNotFound;
    } else if ([channel hasSuffix:@"/**"]) {
        NSString *prefix = [channel substringToIndex:([channel length] - 2)];
        return [m_channel hasPrefix:prefix];
    } else {
        return NO;
    }
}

+(BOOL)channel:(NSString*)parent isParentTo:(NSString*)channel {
    if ([parent hasSuffix:@"/*"]) {
        NSString *prefix = [parent substringToIndex:([parent length] - 1)];
        return [channel hasPrefix:prefix] && [[channel substringFromIndex:([channel length] - 1)] rangeOfString:@"*"].location == NSNotFound;
    } else if ([parent hasSuffix:@"/**"]) {
        NSString *prefix = [parent substringToIndex:([parent length] - 2)];
        return [channel hasPrefix:prefix];
    } else {
        return NO;
    }

}

+(BOOL)channel:(NSString*)subchannel matchesChannel:(NSString*)parent {
    if ([parent isEqualToString:subchannel])
		return YES;
	if ([parent hasSuffix:@"/**"])
	{
		NSString *prefix = [parent substringToIndex:([parent length] - 2)];
        return [subchannel hasPrefix:prefix];
	}
	else if ([parent hasSuffix:@"/*"])
	{
		NSString *prefix = [parent substringToIndex:([parent length] - 1)];
		return ([subchannel hasPrefix:prefix] && [[subchannel substringFromIndex:([subchannel length] - 1)] rangeOfString:@"*"].location == NSNotFound);
	}
	return NO;

}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@-%d", self.channel, self.hash];
}

@end

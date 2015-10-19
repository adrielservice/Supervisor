
#import "DDArrayQueue.h"


@implementation DDArrayQueue

- (id)init
{
	if ((self = [super init]))
	{
		m_array = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)addObject:(id)object
{
	@synchronized(m_array)
	{
		[m_array addObject:object];
	}
	if (m_delegate)
		[m_delegate queueDidAddObject:self];
}

- (id)removeObject
{
	@synchronized(m_array)
	{
		if ([m_array count] == 0)
			return nil;
		id object = m_array[0];
		[m_array removeObjectAtIndex:0];
		return object;
	}
}

- (void)setDelegate:(id<DDQueueDelegate>)delegate
{
	m_delegate = delegate;
}

@end

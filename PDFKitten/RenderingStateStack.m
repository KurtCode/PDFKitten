#import "RenderingStateStack.h"
#import "RenderingState.h"

@implementation RenderingStateStack

+ (RenderingStateStack *)stack {
	return [[RenderingStateStack alloc] init];
}

- (id)init
{
	if ((self = [super init]))
	{
		stack = [[NSMutableArray alloc] init];
		RenderingState *rootRenderingState = [[RenderingState alloc] init];
		[self pushRenderingState:rootRenderingState];
	}
	return self;
}

/* The rendering state currently on top of the stack */
- (RenderingState *)topRenderingState
{
	return [stack lastObject];
}

/* Push a rendering state to the stack */
- (void)pushRenderingState:(RenderingState *)state
{
	[stack addObject:state];
}

/* Pops the top rendering state off the stack */
- (RenderingState *)popRenderingState
{
	RenderingState *state = [stack lastObject];
	[stack removeLastObject];
    
	return state;
}

@end
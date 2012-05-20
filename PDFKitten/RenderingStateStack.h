#import <Foundation/Foundation.h>

@class RenderingState;

@interface RenderingStateStack : NSObject {
	NSMutableArray *stack;
}

/* Push a rendering state to the stack */
- (void)pushRenderingState:(RenderingState *)state;

/* Pops the top rendering state off the stack */
- (RenderingState *)popRenderingState;

/* The rendering state currently on top of the stack */
@property (nonatomic, readonly) RenderingState *topRenderingState;

@end
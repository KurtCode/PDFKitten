#import <Foundation/Foundation.h>

@class RenderingState;

@interface Selection : NSObject {
	RenderingState *initialState;
	CGAffineTransform transform;
	CGRect frame;
}

/* Initalize with rendering state (starting marker) */
- (id)initWithStartState:(RenderingState *)state;

/* Finalize the selection (ending marker) */
- (void)finalizeWithState:(RenderingState *)state;

/* The frame with zero origin covering the selection */
@property (nonatomic, readonly) CGRect frame;

/* The transformation needed to position the selection */
@property (nonatomic, readonly) CGAffineTransform transform;

@end

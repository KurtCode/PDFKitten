#import <Foundation/Foundation.h>
#import "RenderingState.h"


@interface Selection : NSObject {
	RenderingState *startState;
	CGRect frame;
	CGAffineTransform transform;
}

/* Initalize with rendering state */
- (id)initWithStartState:(RenderingState *)state;

/* Finalize the selection */
- (void)finalizeWithState:(RenderingState *)state;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) CGAffineTransform transform;
@end

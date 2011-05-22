#import "Selection.h"


@interface Selection ()
@property (nonatomic, copy) RenderingState *startState;
@end

@implementation Selection

/* Rendering state represents opening (left) cap */
- (id)initWithStartState:(RenderingState *)state
{
	if ((self = [super init]))
	{
		self.startState = state;
	}
	return self;
}

/* Rendering state represents closing (right) cap */
- (void)finalizeWithState:(RenderingState *)state
{
	// Concatenate CTM onto text matrix
	transform = CGAffineTransformConcat([startState textMatrix], [startState ctm]);

	Font *openingFont = [startState font];
	Font *closingFont = [state font];
	
	// Width (difference between caps) with text transformation removed
	CGFloat width = [state textMatrix].tx - [startState textMatrix].tx;	
	width /= [state textMatrix].a;

	// Use tallest cap for entire selection
	CGFloat startHeight = [openingFont maxY] - [openingFont minY];
	CGFloat finishHeight = [closingFont maxY] - [closingFont minY];
	RenderingState *s = (startHeight > finishHeight) ? startState : state;
	
	// Height is ascent plus (negative) descent
	CGFloat height = ([[s font] maxY] - [[s font] minY]) / 1000 * s.fontSize;

	// Descent
	CGFloat descent = [[[s font] fontDescriptor] descent] / 1000 * [s fontSize];

	// Selection frame in text space
	frame = CGRectMake(0, descent, width, height);
}

@synthesize startState, frame, transform;
@end

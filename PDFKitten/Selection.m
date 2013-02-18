#import "Selection.h"
#import "RenderingState.h"

@implementation Selection

+ (Selection *)selectionWithState:(RenderingState *)state {
	Selection *selection = [[Selection alloc] init];
	selection.initialState = state;
	return [selection autorelease];
}

- (CGAffineTransform)transform {
	return CGAffineTransformConcat([self.initialState textMatrix], [self.initialState ctm]);
}

- (CGRect)frame {
	return CGRectMake(0, self.descent, self.width, self.height);
}

- (CGFloat)height {
	return self.ascent - self.descent;
}

- (CGFloat)width {
	CGFloat maxTx = self.finalState.textMatrix.tx / self.finalState.textMatrix.a;
	CGFloat minTx = self.initialState.textMatrix.tx / self.initialState.textMatrix.a;
	return maxTx - minTx;
}

- (CGFloat)ascent {
	return MAX([self ascentInUserSpace:self.initialState], [self ascentInUserSpace:self.finalState]);
}

- (CGFloat)descent {
	return MIN([self descentInUserSpace:self.initialState], [self descentInUserSpace:self.finalState]);
}

- (CGFloat)ascentInUserSpace:(RenderingState *)state {
	return state.font.fontDescriptor.ascent * state.fontSize / 1000;
}

- (CGFloat)descentInUserSpace:(RenderingState *)state {
	return state.font.fontDescriptor.descent * state.fontSize / 1000;
}

@synthesize frame, transform;
@end

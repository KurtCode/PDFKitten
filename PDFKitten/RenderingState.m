#import "RenderingState.h"


@implementation RenderingState

- (id)copyWithZone:(NSZone *)zone
{
	RenderingState *copy = [[RenderingState alloc] init];
	copy.lineMatrix = self.lineMatrix;
	copy.textMatrix = self.textMatrix;
	copy.leadning = self.leadning;
	copy.wordSpacing = self.wordSpacing;
	copy.characterSpacing = self.characterSpacing;
	copy.horizontalScaling = self.horizontalScaling;
	copy.textRise = self.textRise;
	copy.font = self.font;
	copy.fontSize = self.fontSize;
	copy.ctm = self.ctm;
	return copy;
}

- (id)init
{
    if ((self = [super init]))
	{
		// Default values
		self.textMatrix = CGAffineTransformIdentity;
		self.lineMatrix = CGAffineTransformIdentity;
        self.ctm = CGAffineTransformIdentity;
		self.horizontalScaling = 1.0;
    }
    return self;
}

- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace
{
	self.textMatrix = matrix;
	if (replace)
	{
		self.lineMatrix = matrix;
	}
}

- (void)translateTextPosition:(CGSize)size
{
	self.textMatrix = CGAffineTransformTranslate(self.textMatrix, size.width, size.height);
}

- (void)newLineWithLineHeight:(CGFloat)lineHeight indent:(CGFloat)indent save:(BOOL)save
{
	self.lineMatrix = CGAffineTransformTranslate(self.lineMatrix, indent, lineHeight);
	self.textMatrix = self.lineMatrix;
	if (save)
	{
		self.leadning = -lineHeight;
	}
}

- (void)newLineWithLineHeight:(CGFloat)lineHeight save:(BOOL)save
{
	[self newLineWithLineHeight:lineHeight indent:0 save:save];
}

- (void)newLine
{
	[self newLineWithLineHeight:self.leadning save:NO];
}

- (void)dealloc
{
	[font release];
	[super dealloc];
}

@synthesize characterSpacing, wordSpacing, leadning, textRise, horizontalScaling, font, fontSize, lineMatrix, textMatrix, ctm;
@end


@interface RenderingStateStack ()
@property (nonatomic, retain) NSMutableArray *stack;
@end

@implementation RenderingStateStack

- (id)init
{
	if ((self = [super init]))
	{
		RenderingState *rootRenderingState = [[RenderingState alloc] init];
		[self pushRenderingState:rootRenderingState];
		[rootRenderingState release];
	}
	return self;
}

- (RenderingState *)topRenderingState
{
	return [self.stack lastObject];
}

- (void)pushRenderingState:(RenderingState *)state
{
	[self.stack addObject:state];
}

- (RenderingState *)popRenderingState
{
	RenderingState *state = [self.stack lastObject];
	[[stack retain] autorelease];
	[self.stack removeLastObject];
	return state;
}

- (NSMutableArray *)stack
{
	if (!stack)
	{
		stack = [[NSMutableArray alloc] init];
	}
	return stack;
}

- (void)dealloc
{
	[stack release];
	[super dealloc];
}

@synthesize stack;
@end
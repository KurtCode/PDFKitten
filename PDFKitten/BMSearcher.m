#import "BMSearcher.h"

typedef enum {
	BadCharacterRule,
	GoodSuffixRule,
} Rule;

@implementation BMSearcher

- (id)initWithPattern:(NSString *)str
{
	if ([super init])
	{
		self.pattern = str;
	}

	return self;
}

/**
 * Compare pattert to text at current alignment.
 *
 * @param text text
 * @param alignment current alignment
 * @param mismatch will contain the offset of the first mismatch
 * @return offset of first character mismatch
 */
- (BOOL)compare:(NSString *)text alignment:(int)alignment mismatch:(int *)mismatch
{
	int patternMaxIndex = [self.pattern length] - 1;
	for (int i = 0; i < patternMaxIndex; i++)
	{
		if ([text characterAtIndex:alignment-i] != [self.pattern characterAtIndex:patternMaxIndex-i])
		{
			*mismatch = i;
			return NO;
		}
	}
	
	*mismatch = NSNotFound;
	return YES;
}

- (int)shiftWithText:(NSString *)text alignment:(int)alignment mismatch:(int)mismatch rule:(Rule)rule
{
	int mismatchPosition = alignment - mismatch;
	unichar mismatchedChar = [text characterAtIndex:mismatchPosition];
	for (int badCharacterShift = 0; badCharacterShift < mismatchPosition; badCharacterShift++)
	{
		if ([text characterAtIndex:mismatchPosition-badCharacterShift] == mismatchedChar)
		{
			return badCharacterShift;
		}
	}
	
	return 0;
}

- (void)search:(NSString *)text
{	
	int alignment = [self.pattern length] - 1;
	while (alignment < [text length])
	{
		int offset;
		if ([self compare:text alignment:alignment mismatch:&offset])
		{
			NSLog(@"Found at alignment %d", alignment);
		}
		alignment++;
	}
}

- (void)dealloc
{
	[pattern release];
	[super dealloc];
}

@synthesize pattern;
@end

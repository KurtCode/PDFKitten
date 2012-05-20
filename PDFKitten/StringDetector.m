#import "StringDetector.h"


@interface StringDetector ()
- (void)didFindNeedle;
- (BOOL)append:(NSString *)string isLast:(BOOL *)isLast;
- (void)didScanCharacter:(unichar)character;
- (void)didStartDetectingNeedle;

@property (nonatomic, assign) NSUInteger keywordPosition;
@end


@implementation StringDetector

/* Initialize with a key string */
- (id)initWithKeyword:(NSString *)str
{
	if ((self = [super init]))
	{
		self.keyword = str;
	}
	return self;
}

/* Feed a string into the state machine */
- (NSString *)appendPDFString:(CGPDFStringRef)string withFont:(Font *)font
{
	// Use CID string for font-related computations.
	NSString *cidString = [font stringWithPDFString:string];
 	
	// Use Unicode string to compare with user input.
	NSString *unicodeString = [[font stringWithPDFString:string] lowercaseString];
	
	// The string being compared
	NSMutableString *effectiveText = [NSMutableString string];
	
	[unicodeContent appendString:unicodeString];
	
	for (int i = 0; i < [unicodeString length]; i++)
	{
		NSString *needleString = [NSString stringWithFormat:@"%C", [unicodeString characterAtIndex:i]];
		
		// Expand ligatures to separate characters
		needleString = [font stringByExpandingLigatures:needleString];
		[effectiveText appendString:needleString];
		
		BOOL isFirst = (self.keywordPosition == 0);
		BOOL isLast;
		if ([self append:needleString isLast:&isLast])
		{
			if (isFirst)
			{
				// Tell delegate first characher was scanned.
				[self didStartDetectingNeedle];
			}
			
			// Tell delegate another character was scanned.
			// It is critical that this message be sent AFTER the first character
			// of the keyword has been detected, and BEFORE the last character is
			// detected, such that all characters of the keyword fall within the
			// messages corresponding to the start and end of the detected string.
			[self didScanCharacter:[cidString characterAtIndex:i]];
			
			if (isLast)
			{
				// The entire string was found. Inform the delegate
				// and reset for further scanning.
				[self didFindNeedle];
				[self reset];
			}
		}
		else
		{
			// Reset and try again!
			[self reset];
			
			// This covers the case where the character does not match the current
			// position in the keyword, but matches the first.
			if ([self append:needleString isLast:&isLast])
			{
				[self didStartDetectingNeedle];
				
				[self didScanCharacter:[cidString characterAtIndex:i]];
				
				if (isLast)
				{
					[self didFindNeedle];
					[self reset];
				}
			}
			else
			{
				// Tell delegate another character was scanned,
				// and reset in case part of the keyword was already matched.
				[self didScanCharacter:[cidString characterAtIndex:i]];
			}
		}
	}
	return effectiveText;
}

/* Reset the state machine */
- (void)reset
{
	[unicodeContent release];
	unicodeContent = [[NSMutableString alloc] init];
	self.keywordPosition = 0;
}

/* The first characher was detected (e.g. "c" in "cat") */
- (void)didStartDetectingNeedle
{
	if ([delegate respondsToSelector:@selector(detector:didStartMatchingString:)])
	{
		[delegate detector:self didStartMatchingString:self.keyword];
	}
}

/* A character was scanned */
- (void)didScanCharacter:(unichar)character
{
	if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)])
	{
		[delegate detector:self didScanCharacter:character];
	}
}

/* The entire needle has just been detected */
- (void)didFindNeedle
{
	if ([delegate respondsToSelector:@selector(detector:foundString:)])
	{
		// Tell the delegate where the needle was found
		[delegate detector:self foundString:self.keyword];
	}
}

/* The next character to look for */
- (unichar)nextCharacter:(BOOL *)isLast
{
	*isLast = (self.keywordPosition == ([self.keyword length] - 1));
	if (self.keywordPosition >= [self.keyword length]) return 0;
	return [self.keyword characterAtIndex:self.keywordPosition];
}

/* The needle is converted to lowercase */
- (void)setKeyword:(NSString *)string
{
	[keyword release];
	keyword = [[string lowercaseString] retain];
	[self reset];
}

- (BOOL)append:(NSString *)string isLast:(BOOL *)isLast
{
	for (int i = 0; i < [string length]; i++)
	{
		if ([self nextCharacter:isLast] != [string characterAtIndex:i])
		{
			return NO;
		}
		self.keywordPosition++;
	}
	return YES;
}


#pragma mark -
#pragma mark Memory Management

- (NSString *)unicodeContent
{
	return [NSString stringWithString:unicodeContent];
}

- (void)dealloc
{
    [unicodeContent release];
	[keyword release];
	[super dealloc];
}

@synthesize keyword, delegate, keywordPosition;
@end

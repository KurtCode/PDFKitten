#import "StringDetector.h"

@implementation StringDetector

+ (StringDetector *)detectorWithKeyword:(NSString *)keyword delegate:(id<StringDetectorDelegate>)delegate
{
	StringDetector *detector = [[StringDetector alloc] initWithKeyword:keyword];
	detector.delegate = delegate;
	return detector;
}

- (id)initWithKeyword:(NSString *)string
{
	if (self = [super init])
    {
        keyword = [string lowercaseString];
        self.unicodeContent = [NSMutableString string];
	}

	return self;
}

- (NSString *)appendString:(NSString *)inputString
{
	NSString *lowercaseString = [inputString lowercaseString];
    int position = 0;
    
    if (lowercaseString)
    {
        [unicodeContent appendString:lowercaseString];
    }

    while (position < inputString.length)
    {
		unichar inputCharacter = [inputString characterAtIndex:position];
		unichar actualCharacter = [lowercaseString characterAtIndex:position++];
        unichar expectedCharacter = [keyword characterAtIndex:keywordPosition];

        if (actualCharacter != expectedCharacter)
        {
            if (keywordPosition > 0)
            {
                // Read character again
                position--;
            }
			else if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)])
            {
				[delegate detector:self didScanCharacter:inputCharacter];
			}

            // Reset keyword position
            keywordPosition = 0;
            continue;
        }

        if (keywordPosition == 0 && [delegate respondsToSelector:@selector(detectorDidStartMatching:)])
        {
            [delegate detectorDidStartMatching:self];
        }

        if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)])
        {
            [delegate detector:self didScanCharacter:inputCharacter];
        }

        if (++keywordPosition < keyword.length)
        {
            // Keep matching keyword
            continue;
        }

        // Reset keyword position
        keywordPosition = 0;
        
        if ([delegate respondsToSelector:@selector(detectorFoundString:)])
        {
            [delegate detectorFoundString:self];
        }
    }

    return inputString;
}

- (void)setKeyword:(NSString *)kword
{
    keyword = [kword lowercaseString];
    keywordPosition = 0;
}

- (void)reset
{
    keywordPosition = 0;
}

@synthesize delegate, unicodeContent;

@end
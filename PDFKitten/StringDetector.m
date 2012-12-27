#import "StringDetector.h"

@implementation StringDetector

- (id)initWithKeyword:(NSString *)string {
	if (self = [super init]) {
        keyword = [[string lowercaseString] retain];
        self.unicodeContent = [NSMutableString string];
	}

	return self;
}

- (NSString *)appendString:(NSString *)inputString {
	inputString = [inputString lowercaseString];
    int position = 0;
    assert(inputString != nil);
    if (inputString) {
        [unicodeContent appendString:inputString];
    }

    while (position < inputString.length) {
		unichar actualCharacter = [inputString characterAtIndex:position++];
        unichar expectedCharacter = [keyword characterAtIndex:keywordPosition];

        if (actualCharacter != expectedCharacter) {
            if (keywordPosition > 0) {
                // Read character again
                position--;
            }

            // Reset keyword position
            keywordPosition = 0;
            continue;
        }

        if (keywordPosition == 0 && [delegate respondsToSelector:@selector(detectorDidStartMatching:)]) {
            [delegate detectorDidStartMatching:self];
        }

        if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)]) {
            [delegate detector:self didScanCharacter:actualCharacter];
        }

        if (++keywordPosition < keyword.length) {
            // Keep matching keyword
            continue;
        }

        // Reset keyword position
        keywordPosition = 0;
        if ([delegate respondsToSelector:@selector(detectorFoundString:)]) {
            [delegate detectorFoundString:self];
        }
    }

    return inputString;
}

- (NSString *)appendPDFString:(CGPDFStringRef)string withFont:(Font *)font {
    return [self appendString:[font stringWithPDFString:string]];
}

- (void)setKeyword:(NSString *)kword {
    [keyword release];
    keyword = [[kword lowercaseString] retain];

    keywordPosition = 0;
}

- (void)reset {
//    keywordPosition = 0;
}

- (void)dealloc {
    [unicodeContent release];
	[keyword release];
	[super dealloc];
}

@synthesize delegate, unicodeContent;
@end

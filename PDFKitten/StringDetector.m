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
                position--;
            }

            keywordPosition = 0;
            continue;
        }

        if (keywordPosition == 0 && [delegate respondsToSelector:@selector(detector:didStartMatchingString:)]) {
            [delegate detector:self didStartMatchingString:keyword];
        }

        if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)]) {
            [delegate detector:self didScanCharacter:actualCharacter];
        }

        if (++keywordPosition < keyword.length) {
            continue;
        }

        keywordPosition = 0;
        if ([delegate respondsToSelector:@selector(detector:foundString:)]) {
            [delegate detector:self foundString:keyword];
        }
    }
    
    return inputString;
}

- (NSString *)appendPDFString:(CGPDFStringRef)string withFont:(Font *)font {
    return [self appendString:[font stringWithPDFString:string]];
}

- (void)setKeyword:(NSString *)string {
    [keyword release];
    keyword = [[string lowercaseString] retain];
    keywordPosition = 0;
}

- (void)dealloc {
    [unicodeContent release];
	[keyword release];
	[super dealloc];
}

@synthesize delegate, unicodeContent;
@end

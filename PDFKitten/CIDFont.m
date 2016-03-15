#import "CIDFont.h"

@implementation CIDFont

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	unichar *characterIDs = (unichar *) CGPDFStringGetBytePtr(pdfString);
	int length = (int)(CGPDFStringGetLength(pdfString) / sizeof(unichar));
	int magicalOffset = ([self isIdentity] ? 0 : 30);
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		unichar unicodeValue = characterIDs[i] + magicalOffset;
		[unicodeString appendFormat:@"%C", unicodeValue];
	}
    
	return unicodeString;
}

@synthesize identity;
@end

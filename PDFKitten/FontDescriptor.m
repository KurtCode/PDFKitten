#import "FontDescriptor.h"
#import "TrueTypeFont.h"
#import <CommonCrypto/CommonDigest.h>

@interface FontDescriptor ()

@end

@implementation FontDescriptor

- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict
{
	const char *type = nil;
	CGPDFDictionaryGetName(dict, "Type", &type);
	if (!type || strcmp(type, "FontDescriptor") != 0)
	{
		[self release]; return nil;
	}

	if ((self = [super init]))
	{
		CGPDFInteger ascentValue = 0L;
		CGPDFInteger descentValue = 0L;
		CGPDFInteger leadingValue = 0L;
		CGPDFInteger capHeightValue = 0L;
		CGPDFInteger xHeightValue = 0L;
		CGPDFInteger averageWidthValue = 0L;
		CGPDFInteger maxWidthValue = 0L;
		CGPDFInteger missingWidthValue = 0L;
		CGPDFInteger flagsValue = 0L;
		CGPDFInteger stemV = 0L;
		CGPDFInteger stemH = 0L;
		CGPDFInteger italicAngleValue = 0L;
		const char *fontNameString = nil;
		CGPDFArrayRef bboxValue = nil;

		CGPDFDictionaryGetInteger(dict, "Ascent", &ascentValue);
        CGPDFDictionaryGetInteger(dict, "Descent", &descentValue);
        CGPDFDictionaryGetInteger(dict, "Leading", &leadingValue);
		CGPDFDictionaryGetInteger(dict, "CapHeight", &capHeightValue);
		CGPDFDictionaryGetInteger(dict, "XHeight", &xHeightValue);
		CGPDFDictionaryGetInteger(dict, "AvgWidth", &averageWidthValue);
		CGPDFDictionaryGetInteger(dict, "MaxWidth", &maxWidthValue);
		CGPDFDictionaryGetInteger(dict, "MissingWidth", &missingWidthValue);
		CGPDFDictionaryGetInteger(dict, "Flags", &flagsValue);
		CGPDFDictionaryGetInteger(dict, "StemV", &stemV);
        CGPDFDictionaryGetInteger(dict, "StemH", &stemH);
        CGPDFDictionaryGetInteger(dict, "ItalicAngle", &italicAngleValue);
        CGPDFDictionaryGetName(dict, "FontName", &fontNameString);
		CGPDFDictionaryGetArray(dict, "FontBBox", &bboxValue);
        
        self.ascent = ascentValue;
        self.descent = descentValue;
        self.leading = leadingValue;
		self.capHeight = capHeightValue;
		self.xHeight = xHeightValue;
		self.averageWidth = averageWidthValue;
		self.maxWidth = maxWidthValue;
        self.missingWidth = missingWidthValue;
        self.flags = flagsValue;
        self.verticalStemWidth = stemV;
        self.horizontalStemWidth = stemH;
        self.italicAngle = italicAngleValue;
        self.fontName = [NSString stringWithUTF8String:fontNameString];

		if (CGPDFArrayGetCount(bboxValue) == 4)
		{
			CGPDFInteger x = 0, y = 0, width = 0, height = 0;
			CGPDFArrayGetInteger(bboxValue, 0, &x);
			CGPDFArrayGetInteger(bboxValue, 1, &y);
			CGPDFArrayGetInteger(bboxValue, 2, &width);
			CGPDFArrayGetInteger(bboxValue, 3, &height);
			self.bounds = CGRectMake(x, y, width, height);
		}
		
		CGPDFStreamRef fontFileStream;
		if (CGPDFDictionaryGetStream(dict, "FontFile", &fontFileStream))
		{
			CGPDFDataFormat format;
			NSData *data = (NSData *) CGPDFStreamCopyData(fontFileStream, &format);
			
	 		NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
			path = [path stringByAppendingPathComponent:@"fontfile"];
			[data writeToFile:path atomically:YES];
			
			fontFile = [[FontFile alloc] initWithData:data];
			[data release];
		}

	}
	return self;
}

+ (void)parseFontFile:(NSData *)data
{
//	CGPDFDictionaryRef dict = CGPDFStreamGetDictionary(text);
//	
//	CGPDFInteger cleartextLength, decryptedLength, fixedLength;
//	CGPDFInteger totalLength;
//	CGPDFDictionaryGetInteger(dict, "Length1", &cleartextLength);
//	CGPDFDictionaryGetInteger(dict, "Length2", &decryptedLength);
//	CGPDFDictionaryGetInteger(dict, "Length3", &fixedLength);
//	CGPDFDictionaryGetInteger(dict, "Length", &totalLength);
//	
//	NSLog(@"Lengths: %ld, %ld, %ld", cleartextLength, decryptedLength, fixedLength);
//	NSLog(@"Total: %ld", totalLength);
//	
//	CGPDFDataFormat format;
//	CFDataRef data = CGPDFStreamCopyData(text, &format);
//	const uint8_t *ptr = CFDataGetBytePtr(data);
//	size_t length = CFDataGetLength(data);
//	NSData *fontData = [NSData dataWithBytes:ptr length:length];
//
//	size_t digestStringLength = CC_MD5_DIGEST_LENGTH * sizeof(unsigned char);
//	unsigned char *digest = malloc(digestStringLength);
//	bzero(digest, digestStringLength);
//	CC_MD5(data, length, digest);

	// Get first header
	
}

/* True if a font is symbolic */
- (BOOL)isSymbolic
{
	return ((self.flags & FontSymbolic) > 0) && ((self.flags & FontNonSymbolic) == 0);
}

#pragma mark Memory Management

- (void)dealloc
{
	[fontFile release];
	[fontName release];
	[super dealloc];
}

@synthesize ascent, descent, bounds, leading, capHeight, averageWidth, maxWidth, missingWidth, xHeight, flags, verticalStemWidth, horizontalStemWidth, italicAngle, fontName;
@synthesize fontFile;
@end

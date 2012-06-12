#import "FontDescriptor.h"
#import "TrueTypeFont.h"
#import <CommonCrypto/CommonDigest.h>

const char *kAscentKey = "Ascent";
const char *kDescentKey = "Descent";
const char *kLeadingKey = "Leading";
const char *kCapHeightKey = "CapHeight";
const char *kXHeightKey = "XHeight";
const char *kAverageWidthKey = "AvgWidth";
const char *kMaxWidthKey = "MaxWidth";
const char *kMissingWidthKey = "MissingWidth";
const char *kFlagsKey = "Flags";
const char *kStemVKey = "StemV";
const char *kStemHKey = "StemH";
const char *kItalicAngleKey = "ItalicAngle";
const char *kFontNameKey = "FontName";
const char *kFontBBoxKey = "FontBBox";
const char *kFontFileKey = "FontFile";


@implementation FontDescriptor

- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict
{
	const char *type = nil;
	CGPDFDictionaryGetName(dict, kTypeKey, &type);
	if (!type || strcmp(type, kFontDescriptorKey) != 0)
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

		CGPDFDictionaryGetInteger(dict, kAscentKey, &ascentValue);
        CGPDFDictionaryGetInteger(dict, kDescentKey, &descentValue);
        CGPDFDictionaryGetInteger(dict, kLeadingKey, &leadingValue);
		CGPDFDictionaryGetInteger(dict, kCapHeightKey, &capHeightValue);
		CGPDFDictionaryGetInteger(dict, kXHeightKey, &xHeightValue);
		CGPDFDictionaryGetInteger(dict, kAverageWidthKey, &averageWidthValue);
		CGPDFDictionaryGetInteger(dict, kMaxWidthKey, &maxWidthValue);
		CGPDFDictionaryGetInteger(dict, kMissingWidthKey, &missingWidthValue);
		CGPDFDictionaryGetInteger(dict, kFlagsKey, &flagsValue);
		CGPDFDictionaryGetInteger(dict, kStemVKey, &stemV);
        CGPDFDictionaryGetInteger(dict, kStemHKey, &stemH);
        CGPDFDictionaryGetInteger(dict, kItalicAngleKey, &italicAngleValue);
        CGPDFDictionaryGetName(dict, kFontNameKey, &fontNameString);
		CGPDFDictionaryGetArray(dict, kFontBBoxKey, &bboxValue);
        
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
		if (CGPDFDictionaryGetStream(dict, kFontFileKey, &fontFileStream))
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

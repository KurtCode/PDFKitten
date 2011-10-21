#import "FontDescriptor.h"
#import "TrueTypeFont.h"

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
	}
	return self;
}

/* True if a font is symbolic */
- (BOOL)isSymbolic
{
	return ((self.flags & FontSymbolic) > 0) && ((self.flags & FontNonSymbolic) == 0);
}

#pragma mark Memory Management

- (void)dealloc
{
	[fontName release];
	[super dealloc];
}

@synthesize ascent, descent, bounds, leading, capHeight, averageWidth, maxWidth, missingWidth, xHeight, flags, verticalStemWidth, horizontalStemWidth, italicAngle, fontName;
@end

#import "FontDescriptor.h"
#import "TrueTypeFont.h"

@implementation FontDescriptor

- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict
{
	const char *type = nil;
	CGPDFDictionaryGetName(dict, "Type", &type);
	if (strcmp(type, "FontDescriptor") != 0)
	{
		[self release]; return nil;
	}

	if ((self = [super init]))
	{
		CGPDFInteger ascentValue;
		if (CGPDFDictionaryGetInteger(dict, "Ascent", &ascentValue))
		{
			self.ascent = ascentValue;
		}

		CGPDFInteger descentValue;
		if (CGPDFDictionaryGetInteger(dict, "Descent", &descentValue))
		{
			self.descent = descentValue;
		}
		
		CGPDFInteger leadingValue;
		if (CGPDFDictionaryGetInteger(dict, "Leading", &leadingValue))
		{
			self.leading = leadingValue;
		}
		
		CGPDFInteger capHeightValue;
		if (CGPDFDictionaryGetInteger(dict, "CapHeight", &capHeightValue))
		{
			self.capHeight = capHeightValue;
		}
		
		CGPDFInteger xHeightValue;
		if (CGPDFDictionaryGetInteger(dict, "XHeight", &xHeightValue))
		{
			self.xHeight = xHeightValue;
		}
		
		CGPDFInteger averageWidthValue;
		if (CGPDFDictionaryGetInteger(dict, "AvgWidth", &averageWidthValue))
		{
			self.averageWidth = averageWidthValue;
		}
		
		CGPDFInteger maxWidthValue;
		if (CGPDFDictionaryGetInteger(dict, "MaxWidth", &maxWidthValue))
		{
			self.maxWidth = maxWidthValue;
		}
		
		CGPDFInteger missingWidthValue;
		if (CGPDFDictionaryGetInteger(dict, "MissingWidth", &missingWidthValue))
		{
			self.missingWidth = missingWidthValue;
		}
		
		CGPDFArrayRef bboxValue;
		if (CGPDFDictionaryGetArray(dict, "FontBBox", &bboxValue))
		{
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
		
		CGPDFInteger flagsValue;
		if (CGPDFDictionaryGetInteger(dict, "Flags", &flagsValue))
		{
			self.flags = flagsValue;
		}
		
		CGPDFInteger stemV;
		if (CGPDFDictionaryGetInteger(dict, "StemV", &stemV))
		{
			self.verticalStemWidth = stemV;
		}
		
		CGPDFInteger stemH;
		if (CGPDFDictionaryGetInteger(dict, "StemH", &stemH))
		{
			self.horizontalStemWidth = stemH;
		}
		
		CGPDFInteger italicAngleValue;
		if (CGPDFDictionaryGetInteger(dict, "ItalicAngle", &italicAngleValue))
		{
			self.italicAngle = italicAngleValue;
		}
		
		const char *fontNameString;
		if (CGPDFDictionaryGetName(dict, "FontName", &fontNameString))
		{
			self.fontName = [NSString stringWithUTF8String:fontNameString];
		}
	}
	return self;
}

- (BOOL)isSymbolic
{
	return ((self.flags & FontSymbolic) > 0) && ((self.flags & FontNonSymbolic) == 0);
}

- (void)dealloc
{
	[fontName release];
	[super dealloc];
}


@synthesize ascent, descent, bounds, leading, capHeight, averageWidth, maxWidth, missingWidth, xHeight, flags, verticalStemWidth, horizontalStemWidth, italicAngle, fontName;
@end

#import "Type0Font.h"
#import "CIDType0Font.h"
#import "CIDType2Font.h"


@interface Type0Font ()
@property (nonatomic, readonly) NSMutableArray *descendantFonts;
@end

@implementation Type0Font

/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super initWithFontDictionary:dict]))
	{
		CGPDFArrayRef dFonts;
		if (CGPDFDictionaryGetArray(dict, "DescendantFonts", &dFonts))
		{
			NSUInteger count = CGPDFArrayGetCount(dFonts);
			for (int i = 0; i < count; i++)
			{
				CGPDFDictionaryRef fontDict;
				if (!CGPDFArrayGetDictionary(dFonts, i, &fontDict)) continue;
				const char *subtype;
				if (!CGPDFDictionaryGetName(fontDict, "Subtype", &subtype)) continue;

				if (strcmp(subtype, "CIDFontType0") == 0)
				{
					// Add descendant font of type 0
					CIDType0Font *font = [[CIDType0Font alloc] initWithFontDictionary:fontDict];
					if (font) [self.descendantFonts addObject:font];
					[font release];
				}
				else if (strcmp(subtype, "CIDFontType2") == 0)
				{
					// Add descendant font of type 2
					CIDType2Font *font = [[CIDType2Font alloc] initWithFontDictionary:fontDict];
					if (font) [self.descendantFonts addObject:font];
					[font release];
				}
			}
		}
	}
	return self;
}

/* Custom implementation, using descendant fonts */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize
{
	for (Font *font in self.descendantFonts)
	{
		CGFloat width = [font widthOfCharacter:characher withFontSize:fontSize];
		if (width > 0) return width;
	}
	return 0;
}


#pragma mark -
#pragma mark Memory Management

- (NSMutableArray *)descendantFonts
{
	if (!descendantFonts)
	{
		descendantFonts = [[NSMutableArray alloc] init];
	}
	return descendantFonts;
}

- (void)dealloc
{
	[descendantFonts release];
	[super dealloc];
}

@end

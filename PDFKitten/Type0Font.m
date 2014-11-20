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

				NSLog(@"Descendant font type %s", subtype);

				if (strcmp(subtype, "CIDFontType0") == 0)
				{
					// Add descendant font of type 0
					CIDType0Font *font = [[CIDType0Font alloc] initWithFontDictionary:fontDict];
					if (font) [self.descendantFonts addObject:font];
				}
				else if (strcmp(subtype, "CIDFontType2") == 0)
				{
					// Add descendant font of type 2
					CIDType2Font *font = [[CIDType2Font alloc] initWithFontDictionary:fontDict];
					if (font) [self.descendantFonts addObject:font];
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
	return self.defaultWidth;
}

- (NSDictionary *)ligatures
{
    return [[self.descendantFonts lastObject] ligatures];
}

- (FontDescriptor *)fontDescriptor {
	Font *descendantFont = [self.descendantFonts lastObject];
	return descendantFont.fontDescriptor;
}

- (CGFloat)minY
{
	Font *descendantFont = [self.descendantFonts lastObject];
	return [descendantFont.fontDescriptor descent];
}

/* Highest point of any character */
- (CGFloat)maxY
{
	Font *descendantFont = [self.descendantFonts lastObject];
	return [descendantFont.fontDescriptor ascent];
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	if (self.toUnicode)
	{
		size_t stringLength = CGPDFStringGetLength(pdfString);
		const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
		NSMutableString *unicodeString = [NSMutableString string];
		
        for (int i = 0; i < stringLength; i+=2)
		{
			unichar characterCode = characterCodes[i] << 8 | characterCodes[i+1];
			unichar characterSelector = [self.toUnicode unicodeCharacter:characterCode];
            [unicodeString appendFormat:@"%C", characterSelector];
		}
		return unicodeString;
	}
	else if ([self.descendantFonts count] > 0)
	{
		Font *descendantFont = [self.descendantFonts lastObject];
		return [descendantFont stringWithPDFString:pdfString];
	}
	return @"";
}

- (NSString *)unicodeWithPDFString:(CGPDFStringRef)pdfString
{
    NSMutableString *result;
	Font *descendantFont = [self.descendantFonts lastObject];
    NSString *descendantResult = [descendantFont stringWithPDFString: pdfString];
    
    if (self.toUnicode)
    {
        result = [[NSMutableString alloc] initWithCapacity: [descendantResult length]];
        
        for (int i = 0; i < [descendantResult length]; i++)
        {
            unichar character = [self.toUnicode unicodeCharacter:[descendantResult characterAtIndex:i]];
		 	[result appendFormat:@"%C", character];
        }        
    }
    else
    {
        result = [NSMutableString stringWithString: descendantResult];
    }
    
    return result;
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    Font *descendantFont = [self.descendantFonts lastObject];
    return [descendantFont stringWithPDFString: pdfString];
}

#pragma mark Memory Management

- (NSMutableArray *)descendantFonts
{
	if (!descendantFonts)
	{
		descendantFonts = [[NSMutableArray alloc] init];
	}
    
	return descendantFonts;
}

@end
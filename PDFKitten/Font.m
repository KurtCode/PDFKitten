#import "Font.h"

// Simple fonts
#import "Type1Font.h"
#import "TrueTypeFont.h"
#import "MMType1Font.h"
#import "Type3Font.h"

// Composite fonts
#import "Type0Font.h"
#import "CIDType2Font.h"
#import "CIDType0Font.h"


#pragma mark 

@implementation Font

#pragma mark - Initialization

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font *)fontWithDictionary:(CGPDFDictionaryRef)dictionary
{
	const char *type = nil;
	CGPDFDictionaryGetName(dictionary, "Type", &type);
	if (!type || strcmp(type, "Font") != 0) return nil;
	const char *subtype = nil;
	CGPDFDictionaryGetName(dictionary, "Subtype", &subtype);

	if (strcmp(subtype, "Type0") == 0)
	{
		return [[[Type0Font	alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "Type1") == 0)
	{
		return [[[Type1Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "MMType1") == 0)
	{
		return [[[MMType1Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "Type3") == 0)
	{
		return [[[Type3Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "TrueType") == 0)
	{
		return [[[TrueTypeFont alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "CIDFontType0") == 0)
	{
		return [[[CIDType0Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "CIDFontType2") == 0)
	{
		return [[[CIDType2Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	return nil;
}

/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		// Populate the glyph widths store
		[self setWidthsWithFontDictionary:dict];
		
		// Initialize the font descriptor
		[self setFontDescriptorWithFontDictionary:dict];
		
		// Parse ToUnicode map
		[self setToUnicodeWithFontDictionary:dict];
		
		// NOTE: Any furhter initialization is performed by the appropriate subclass
	}
	return self;
}

#pragma mark Font Resources

/* Import font descriptor */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFDictionaryRef descriptor;
	if (!CGPDFDictionaryGetDictionary(dict, "FontDescriptor", &descriptor)) return;
	FontDescriptor *desc = [[FontDescriptor alloc] initWithPDFDictionary:descriptor];
	self.fontDescriptor = desc;
	[desc release];
}

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	// Custom implementation in subclasses
}

/* Parse the ToUnicode map */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFStreamRef stream;
	if (!CGPDFDictionaryGetStream(dict, "ToUnicode", &stream)) return;
	CMap *map = [[CMap alloc] initWithPDFStream:stream];
	self.toUnicode = map;
	[map release];
}

#pragma mark Font Property Accessors

/* Subclasses will override this method with their own implementation */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    // Copy PDFString to NSString
    NSString *string = (NSString *) CGPDFStringCopyTextString(pdfString);
	return [string autorelease];
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    // Copy PDFString to NSString
    NSString *string = (NSString *) CGPDFStringCopyTextString(pdfString);
	return [string autorelease];
}

/* Lowest point of any character */
- (CGFloat)minY
{
	return [self.fontDescriptor descent];
}

/* Highest point of any character */
- (CGFloat)maxY
{
	return [self.fontDescriptor ascent];
}

/* Width of the given character (CID) scaled to fontsize */
- (CGFloat)widthOfCharacter:(unichar)character withFontSize:(CGFloat)fontSize
{
	NSNumber *key = [NSNumber numberWithInt:character];
	NSNumber *width = [self.widths objectForKey:key];
	return [width floatValue] * fontSize;
}

/* Ligatures available in the current font encoding */
- (NSDictionary *)ligatures
{
	if (!ligatures)
	{
		// Mapping ligature Unicode character values to strings
		ligatures = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"ff", [NSString stringWithFormat:@"%C", 0xfb00],
					 @"fi", [NSString stringWithFormat:@"%C", 0xfb01],
					 @"fl", [NSString stringWithFormat:@"%C", 0xfb02],
					 @"ae", [NSString stringWithFormat:@"%C", 0x00e6],
					 @"oe", [NSString stringWithFormat:@"%C", 0x0153],
					 nil];
	}
	return ligatures;
}

/* Width of space chacacter in glyph space */
- (CGFloat)widthOfSpace
{
	return [self widthOfCharacter:0x20 withFontSize:1.0];
}

/* Description is the class name of the object */
- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@>", [self.class description]];
}

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters
{
	return 0;
}


#pragma mark Memory Management

- (void)dealloc
{
	[toUnicode release];
	[widths release];
	[fontDescriptor release];
	[super dealloc];
}

@synthesize fontDescriptor, widths, toUnicode, widthsRange;
@end

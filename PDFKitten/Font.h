/*
 *	Implements generic behavior of a font.
 *
 *	Most likely used exclusively for subclassing, for Type 0, Type 1 etc.
 *
 *	Ideally, the subclasses are hidden from the user, who interacts with them through this facade class.
 *	
 */
#import <Foundation/Foundation.h>
#import "FontDescriptor.h"
#import "CMap.h"

extern const char *kFontDescriptorKey;
extern const char *kTypeKey;

typedef enum {
	UnknownEncoding = 0,
	StandardEncoding, // Defined in Type1 font programs
	MacRomanEncoding,
	WinAnsiEncoding,
	PDFDocEncoding,
	MacExpertEncoding,
	
} CharacterEncoding;

static inline NSStringEncoding nativeEncoding(CharacterEncoding encoding)
{
	switch (encoding) {
		case MacRomanEncoding :
			return NSMacOSRomanStringEncoding;
		case WinAnsiEncoding :
			return NSWindowsCP1252StringEncoding;
		default:
			return NSUTF8StringEncoding;
	}
}

static inline BOOL knownEncoding(CharacterEncoding encoding)
{
	return encoding > 0;
}

@interface Font : NSObject {
	CMap *toUnicode;
	NSMutableDictionary *widths;
    FontDescriptor *fontDescriptor;
	NSDictionary *ligatures;
	NSRange widthsRange;
	NSString *baseFont;
	CharacterEncoding encoding;
}

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font *)fontWithDictionary:(CGPDFDictionaryRef)dictionary;

/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Construct a font descriptor given font dictionary */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Given a PDF string, returns a Unicode string */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString;

/* Returns the width of a charachter (externionally scaled to some font size) */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize;

/* Import a ToUnicode CMap from a font dictionary */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Return an equivalent string, replacing ligatures with individual characters */
- (NSString *)stringByExpandingLigatures:(NSString *)string;

@property (nonatomic, retain) CMap *toUnicode;
@property (nonatomic, retain) NSMutableDictionary *widths;
@property (nonatomic, retain) FontDescriptor *fontDescriptor;
@property (nonatomic, readonly) CGFloat minY;
@property (nonatomic, readonly) CGFloat maxY;
@property (nonatomic, readonly) NSDictionary *ligatures;
@property (nonatomic, readonly) CGFloat widthOfSpace;
@property (nonatomic, readonly) NSRange widthsRange;
@property (nonatomic, assign) CharacterEncoding encoding;
@property (nonatomic, readonly) NSArray *descendantFonts;

/*!
 @property baseFont
 */
@property (nonatomic, retain) NSString *baseFont;

/*!
 * The actual name of the base font, sans tag.
 @property baseFontName
 */
@property (nonatomic, readonly) NSString *baseFontName;
@end

#import "FontCollection.h"


@interface FontCollection ()
@property (nonatomic, retain) NSMutableDictionary *fonts;
@end

@implementation FontCollection

/* Applier function for font dictionaries */
void didScanFont(const char *key, CGPDFObjectRef object, void *collection)
{
	NSLog(@"%s", key);
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) return;
	CGPDFDictionaryRef dict;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
	Font *font = [Font fontWithDictionary:dict];
	if (!font) return;
	[(NSMutableDictionary *)collection setObject:font forKey:[NSString stringWithUTF8String:key]];
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		// Enumerate the Font resource dictionary
		CGPDFDictionaryApplyFunction(dict, didScanFont, self.fonts);
	}
	return self;
}

/* Returns a copy of the font dictionary */
- (NSDictionary *)fontsByName
{
	return [NSDictionary dictionaryWithDictionary:self.fonts];
}

/* Return the specified font */
- (Font *)fontNamed:(NSString *)fontName
{
	return [self.fonts objectForKey:fontName];
}


#pragma mark - 
#pragma mark Memory Management

- (NSMutableDictionary *)fonts
{
	if (!fonts)
	{
		fonts = [[NSMutableDictionary alloc] init];
	}
	return fonts;
}

- (void)dealloc
{
	[fonts release];
	[super dealloc];
}

@synthesize fonts;
@end

#import "FontCollection.h"


@implementation FontCollection

/* Applier function for font dictionaries */
void didScanFont(const char *key, CGPDFObjectRef object, void *collection)
{
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) return;
	CGPDFDictionaryRef dict;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
	Font *font = [Font fontWithDictionary:dict];
	if (!font) return;
	NSString *name = [NSString stringWithUTF8String:key];
	[(__bridge NSMutableDictionary *)collection setObject:font forKey:name];
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		fonts = [[NSMutableDictionary alloc] init];
		// Enumerate the Font resource dictionary
		CGPDFDictionaryApplyFunction(dict, didScanFont, (__bridge void *)(fonts));

		NSMutableArray *namesArray = [NSMutableArray array];
		
        for (NSString *name in [fonts allKeys])
		{
			[namesArray addObject:name];
		}

		names = [namesArray sortedArrayUsingSelector:@selector(compare:)];
	}
    
	return self;
}

/* Returns a copy of the font dictionary */
- (NSDictionary *)fontsByName
{
	return [NSDictionary dictionaryWithDictionary:fonts];
}

/* Return the specified font */
- (Font *)fontNamed:(NSString *)fontName
{
	return [fonts objectForKey:fontName];
}

@synthesize names;

@end
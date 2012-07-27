#import "CIDType2Font.h"


@implementation CIDType2Font

- (void)setCIDToGIDMapWithDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFObjectRef object = nil;
	if (!CGPDFDictionaryGetObject(dict, "CIDToGIDMap", &object)) return;
	CGPDFObjectType type = CGPDFObjectGetType(object);
	if (type == kCGPDFObjectTypeName)
	{
		const char *mapName;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &mapName)) return;
		identity = YES;
	}
	else if (type == kCGPDFObjectTypeStream)
	{
		CGPDFStreamRef stream = nil;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeStream, &stream)) return;
		NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
		NSLog(@"CIDType2Font: no implementation for CID mapping with stream (%d bytes)", [data length]);
		[data release];
	}
}


- (void)setCIDSystemInfoWithDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFDictionaryRef cidSystemInfo;
	if (!CGPDFDictionaryGetDictionary(dict, "CIDSystemInfo", &cidSystemInfo)) return;

	CGPDFStringRef registry;
	if (!CGPDFDictionaryGetString(cidSystemInfo, "Registry", &registry)) return;

	CGPDFStringRef ordering;
	if (!CGPDFDictionaryGetString(cidSystemInfo, "Ordering", &ordering)) return;
	
	CGPDFInteger supplement;
	if (!CGPDFDictionaryGetInteger(cidSystemInfo, "Supplement", &supplement)) return;
	
	NSString *registryString = (NSString *) CGPDFStringCopyTextString(registry);
	NSString *orderingString = (NSString *) CGPDFStringCopyTextString(ordering);
	
	NSString *cidSystemString = [NSString stringWithFormat:@"%@ (%@) %ld", registryString, orderingString, supplement];
	NSLog(@"%@", cidSystemString);
	
	[registryString release];
	[orderingString release];
}

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super initWithFontDictionary:dict]))
	{
		[self setCIDToGIDMapWithDictionary:dict];
		[self setCIDSystemInfoWithDictionary:dict];
	}
	return self;
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	unichar *characterIDs = (unichar *) CGPDFStringGetBytePtr(pdfString);
	int length = CGPDFStringGetLength(pdfString) / sizeof(unichar);
	int magicalOffset = ([self isIdentity] ? 0 : 30);
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		unichar unicodeValue = characterIDs[i] + magicalOffset;
		[unicodeString appendFormat:@"%C", unicodeValue];
	}

	return unicodeString;
}

@synthesize identity;
@end

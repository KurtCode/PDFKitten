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
		self.identity = YES;
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
	
	NSString *cidSystemString = [NSString stringWithFormat:@"%@ (%@) %d", registryString, orderingString, supplement];
	NSLog(@"%@", cidSystemString);
	
	[registryString release];
	[orderingString release];
}

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	NSLog(@"CID FONT TYPE 2");
	if ((self = [super initWithFontDictionary:dict]))
	{
		[self setCIDToGIDMapWithDictionary:dict];
		[self setCIDSystemInfoWithDictionary:dict];
	}
	return self;
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	if (self.identity)
	{
		// Use 2-byte CIDToGID identity mapping
		size_t length = CGPDFStringGetLength(pdfString);
		const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);

		
		NSData *data = [NSData dataWithBytes:cid length:length];
		NSLog(@"%@", data);
		
		for (int i = 0; i < length; i+=2)
		{
			unichar unicodeValue = cid[i] << 8 | cid[i+1];
//			unichar unicodeValue = 0x4ea4;  
			NSLog(@"%C %x", unicodeValue, unicodeValue);
		}
		
		
	}
	else
	{
		
	}
	
	
	return @"";
}

@synthesize identity;
@end

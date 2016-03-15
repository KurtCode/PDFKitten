#import "CIDType2Font.h"


@implementation CIDType2Font

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if (self = [super initWithFontDictionary:dict])
	{
        // Type 2 CID font only: set CID/GID mapping
        CGPDFObjectRef streamOrName = nil;
        
        if (CGPDFDictionaryGetObject(dict, "CIDToGIDMap", &streamOrName))
        {
            CGPDFObjectType type = CGPDFObjectGetType(streamOrName);
            identity = (type == kCGPDFObjectTypeName);
            
            if (type == kCGPDFObjectTypeStream)
            {
                CGPDFStreamRef stream = nil;
                if (CGPDFObjectGetValue(streamOrName, kCGPDFObjectTypeStream, &stream))
                {
                    cidGidMap = (__bridge NSData *) CGPDFStreamCopyData(stream, nil);
                }
            }
        }
	}

	return self;
}

- (unichar)gidWithCid:(unsigned char)cid
{
    void *gid = nil;
    [cidGidMap getBytes:gid range:NSMakeRange(cid * 2, 2)];
    return (unichar) gid;
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	size_t length = CGPDFStringGetLength(pdfString);
	const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);
    NSMutableString *result = [[NSMutableString alloc] init];
    NSData *data = [NSData dataWithBytes:cid length:length];
    NSLog(@"%@", data);
	for (int i = 0; i < length; i+=2) {
		unsigned char unicodeValue1 = cid[i];
		unsigned char unicodeValue2 = cid[i+1];
        unichar unicodeValue = (unicodeValue1 << 8) + unicodeValue2;
        [result appendFormat:@"%C", unicodeValue];
	}
    return result;
}

/*

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
*/

@end

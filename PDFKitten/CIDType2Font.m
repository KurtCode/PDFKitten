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
                    cidGidMap = (NSData *) CGPDFStreamCopyData(stream, nil);
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

- (void)dealloc
{
    [cidGidMap release];
    [super dealloc];
}

@end

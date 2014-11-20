#import "SimpleFont.h"


@implementation SimpleFont

/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super initWithFontDictionary:dict]))
	{
		// Set encoding for any font
		[self setEncodingWithFontDictionary:dict];
	}
	return self;
}

/* Custom implementation for all simple fonts */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFArrayRef array;
	if (!CGPDFDictionaryGetArray(dict, "Widths", &array)) return;
	size_t count = CGPDFArrayGetCount(array);
	CGPDFInteger firstChar, lastChar;
	if (!CGPDFDictionaryGetInteger(dict, "FirstChar", &firstChar)) return;
	if (!CGPDFDictionaryGetInteger(dict, "LastChar", &lastChar)) return;
	widthsRange = NSMakeRange(firstChar, lastChar-firstChar);
	NSMutableDictionary *widthsDict = [NSMutableDictionary dictionary];
	for (int i = 0; i < count; i++)
	{
		CGPDFReal width;
		if (!CGPDFArrayGetNumber(array, i, &width)) continue;
		NSNumber *key = [NSNumber numberWithInt:firstChar+i];
		NSNumber *value = [NSNumber numberWithFloat:width];
		[widthsDict setObject:value forKey:key];
	}
	self.widths = widthsDict;
}

/* Set encoding, given a font dictionary */
- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFObjectRef encodingObject;
	if (!CGPDFDictionaryGetObject(dict, "Encoding", &encodingObject)) return;
	[self setEncodingWithEncodingObject:encodingObject];
}

/* Custom implementation for all simple fonts */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	const unsigned char *bytes = CGPDFStringGetBytePtr(pdfString);
	NSUInteger length = CGPDFStringGetLength(pdfString);
	if (!self.encoding && self.toUnicode)
	{
		// Use ToUnicode map
		NSMutableString *unicodeString = [NSMutableString string];

		// Translate to Unicode
		for (int i = 0; i < length; i++)
		{
			unichar cid = bytes[i];
            unichar uni = [self.toUnicode unicodeCharacter:cid];
            //NSLog(@"(%hu) %C -> (%hu) %C", cid, cid, uni, uni);
            [unicodeString appendFormat:@"%C", uni];
		}
		
		return unicodeString;
	}
	else if (!self.encoding)
	{
		return [super stringWithPDFString:pdfString];
	}
    NSData *rawBytes = [NSData dataWithBytes:bytes length:length];
	NSString *string = [[NSString alloc] initWithData:rawBytes encoding:nativeEncoding(self.encoding)];
                    
	return string;
}

/* Set encoding with name or dictionary */
- (void)setEncodingWithEncodingObject:(CGPDFObjectRef)object
{
	CGPDFObjectType type = CGPDFObjectGetType(object);
	
	/* Encoding dictionary with base encoding and differences */
	if (type == kCGPDFObjectTypeDictionary)
	{
		/*	NOTE: Also needs to capture differences */
		CGPDFDictionaryRef dict = nil;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
		CGPDFObjectRef baseEncoding = nil;
		if (!CGPDFDictionaryGetObject(dict, "BaseEncoding", &baseEncoding)) return;
		[self setEncodingWithEncodingObject:baseEncoding];
		return;
	}
	
	/* Only accept name objects */
	if (type != kCGPDFObjectTypeName) return;
	
	const char *name;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &name)) return;
	
	if (strcmp(name, "MacRomanEncoding") == 0)
	{
		self.encoding = MacRomanEncoding;
	}
	else if (strcmp(name, "MacExpertEncoding") == 0)
	{
		// What is MacExpertEncoding ??
		self.encoding = MacRomanEncoding;
	}
	else if (strcmp(name, "WinAnsiEncoding") == 0)
	{
		self.encoding = WinAnsiEncoding;
	}
}

/* Unicode character with CID */
//- (NSString *)stringWithCharacters:(const char *)characters
//{
//	return [NSString stringWithCString:characters encoding:encoding];
//}

- (CGFloat)widthOfSpace
{
    unichar c = 0x20;
    
    if (self.toUnicode)
    {
        c = [self.toUnicode cidCharacter:c];
        
        if (c == NSNotFound)
        {
            return 0;
        }
    }
    
    return [self widthOfCharacter:c withFontSize:1.0];
}

@end
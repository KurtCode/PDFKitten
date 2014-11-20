#import "CompositeFont.h"

@implementation CompositeFont

/* Override with implementation for composite fonts */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFArrayRef widthsArray;
	
    if (CGPDFDictionaryGetArray(dict, "W", &widthsArray))
    {
        [self setWidthsWithArray:widthsArray];
    }

	CGPDFInteger defaultWidthValue;
	
    if (CGPDFDictionaryGetInteger(dict, "DW", &defaultWidthValue))
	{
		self.defaultWidth = defaultWidthValue;
	}
}

- (void)setWidthsWithArray:(CGPDFArrayRef)widthsArray
{
    NSUInteger length = CGPDFArrayGetCount(widthsArray);
    int idx = 0;
    CGPDFObjectRef nextObject = nil;
    
    while (idx < length)
    {
        CGPDFInteger baseCid = 0;
        CGPDFArrayGetInteger(widthsArray, idx++, &baseCid);

        CGPDFObjectRef integerOrArray = nil;
        CGPDFInteger firstCharacter = 0;
		CGPDFArrayGetObject(widthsArray, idx++, &integerOrArray);
		
        if (CGPDFObjectGetType(integerOrArray) == kCGPDFObjectTypeInteger)
		{
            // [ first last width ]
			CGPDFInteger maxCid;
			CGPDFInteger glyphWidth;
			CGPDFObjectGetValue(integerOrArray, kCGPDFObjectTypeInteger, &maxCid);
			CGPDFArrayGetInteger(widthsArray, idx++, &glyphWidth);
			[self setWidthsFrom:baseCid to:maxCid width:glyphWidth];

			// If the second item is an array, the sequence
			// defines widths on the form [ first list-of-widths ]
			CGPDFArrayRef characterWidths;
			
            if (!CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeArray, &characterWidths))
            {
                break;
            }
			
            NSUInteger widthsCount = CGPDFArrayGetCount(characterWidths);
			
            for (int index = 0; index < widthsCount ; index++)
			{
				CGPDFInteger width;
			
                if (CGPDFArrayGetInteger(characterWidths, index, &width))
				{
					NSNumber *key = [NSNumber numberWithInt: (int)firstCharacter + index];
					NSNumber *val = [NSNumber numberWithInt: (int)width];
					[widths setObject:val forKey:key];
				}
			}
		}
		else
		{
            // [ first list-of-widths ]
			CGPDFArrayRef glyphWidths;
			CGPDFObjectGetValue(integerOrArray, kCGPDFObjectTypeArray, &glyphWidths);
            [self setWidthsWithBase:baseCid array:glyphWidths];
        }
	}
}

- (void)setWidthsFrom:(CGPDFInteger)cid to:(CGPDFInteger)maxCid width:(CGPDFInteger)width
{
    while (cid <= maxCid)
    {
        [self.widths setObject:[NSNumber numberWithInt:(int)width] forKey:[NSNumber numberWithInt:(int)cid++]];
    }
}

- (void)setWidthsWithBase:(CGPDFInteger)base array:(CGPDFArrayRef)array
{
    NSInteger count = CGPDFArrayGetCount(array);
    CGPDFInteger width;
    
    for (int index = 0; index < count ; index++)
    {
        if (CGPDFArrayGetInteger(array, index, &width))
        {
            [self.widths setObject:[NSNumber numberWithInt:(int)width] forKey:[NSNumber numberWithInt:(int)base + index]];
        }
    }
}

- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize
{
	NSNumber *width = [self.widths objectForKey:[NSNumber numberWithInt:characher - 30]];
	
    if (!width)
	{
		return self.defaultWidth * fontSize;
	}
	
    return [width floatValue] * fontSize;
}

@synthesize defaultWidth;

@end
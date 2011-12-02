#import "CMap.h"
#import "TrueTypeFont.h"

@implementation CMap

- (void)scanCodeSpaceRange:(NSScanner *)scanner
{
	static NSString *endToken = @"endcodespacerange";
	NSString *content = nil;
	[scanner scanUpToString:endToken intoString:&content];
	[scanner scanString:endToken intoString:nil];
	NSLog(@"%@", content);
}

- (void)scanRanges:(NSScanner *)scanner
{
	NSString *content = nil;
	static NSString *endToken = @"endbfrange";
	[scanner scanUpToString:endToken intoString:&content];
	NSCharacterSet *alphaNumericalSet = [NSCharacterSet alphanumericCharacterSet];
	
	offsets = [[NSMutableArray alloc] init];
	NSScanner *rangeScanner = [NSScanner scannerWithString:content];
	while (![rangeScanner isAtEnd])
	{
		unsigned int start, end, offset;
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&start];
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&end];
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&offset];
//		NSLog(@"%d,%d offset %d", start, end, offset);
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:start], @"First",
							  [NSNumber numberWithInt:end], @"Last",
							  [NSNumber numberWithInt:offset], @"Offset", 
							  nil];
		[offsets addObject:dict];

	}
	[scanner scanString:endToken intoString:nil];
}

- (void)scanChars:(NSScanner *)scanner 
{
	NSString *content = nil;
	static NSString *endToken = @"endbfchar";
	[scanner scanUpToString:endToken intoString:&content];
    NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
    NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *separatorString = @"> <";
    
    chars = [[NSMutableDictionary alloc] init];    
    NSScanner *rangeScanner = [NSScanner scannerWithString:content];
    while (![rangeScanner isAtEnd])
    {
        NSString *line = nil;
        [rangeScanner scanUpToCharactersFromSet:newLineSet intoString:&line];
        line = [line stringByTrimmingCharactersInSet:tagSet];
        NSArray *parts = [line componentsSeparatedByString:separatorString];
        
        NSUInteger from, to;
        NSScanner *scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanHexInt:&from];
        NSNumber *fromNumber = [NSNumber numberWithInt:from];
        
        NSString *toString = [parts objectAtIndex:1];
        int charLen = 4;
        if ([toString length] > charLen) {
            NSMutableArray *toArray = [NSMutableArray arrayWithCapacity: [toString length]/4 + ([toString length]%4 > 0 ? 1 : 0)];
            NSRange range;
            NSString *nextTo;
            for (int offset = 0; offset < [toString length]/4; offset++) {
                range = NSMakeRange(offset * charLen, charLen);
                nextTo = [toString substringWithRange: range];
                scanner = [NSScanner scannerWithString: nextTo];
                [scanner scanHexInt: &to];
                [toArray addObject: [NSNumber numberWithInt:to]];
            }
            [chars setObject: toArray forKey:fromNumber];
        }
        else 
        {
            scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
            [scanner scanHexInt:&to];
            NSNumber *toNumber = [NSNumber numberWithInt:to];
            [chars setObject:toNumber  forKey:fromNumber];
        }
    }
    
}

- (void)scanCMap:(NSScanner *)scanner
{
	while (![scanner isAtEnd])
	{
		NSString *line;
		[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
		if ([line rangeOfString:@"begincodespacerange"].location != NSNotFound)
		{
			[self scanCodeSpaceRange:scanner];
		}
		else if ([line rangeOfString:@"beginbfrange"].location != NSNotFound)
		{
			[self scanRanges:scanner];
		}
        else if ([line rangeOfString:@"beginbfchar"].location != NSNotFound) 
        {
            [self scanChars:scanner];
        }
	}
}

- (void)scanning:(NSString *)text
{
	NSScanner *scanner = [NSScanner scannerWithString:text];
	[scanner scanUpToString:@"begincmap" intoString:nil];
	[scanner scanString:@"begincmap" intoString:nil];
	NSLog(@"%d", scanner.scanLocation);
	[self scanCMap:scanner];
}

- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	if ((self = [super init]))
	{
		NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
		NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[data release];
		
		[self scanning:text];
		return self;
		

//		NSScanner *scanner = [NSScanner scannerWithString:text];
//		[scanner scanUpToString:@"beginbfrange" intoString:nil];
//		[scanner scanUpToString:@"<" intoString:nil];
//		NSString *characterRange = nil;
//		[scanner scanUpToString:@"endbfrange" intoString:&characterRange];
//		
//		NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
//		NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
//		NSString *separatorString = @"><";
//
//		offsets = [[NSMutableArray alloc] init];
//		
//		NSScanner *rangeScanner = [NSScanner scannerWithString:characterRange];
//		while (![rangeScanner isAtEnd])
//		{
//			NSString *line = nil;
//			[rangeScanner scanUpToCharactersFromSet:newLineSet intoString:&line];
//			line = [line stringByTrimmingCharactersInSet:tagSet];
//			NSArray *parts = [line componentsSeparatedByString:separatorString];
//			if ([parts count] < 3) continue;
//			
//			NSUInteger from, to, offset;
//			NSScanner *scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
//			[scanner scanHexInt:&from];
//			
//			scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
//			[scanner scanHexInt:&to];
//			
//			scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
//			[scanner scanHexInt:&offset];
//			
//			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//								  [NSNumber numberWithInt:from],	@"First",
//								  [NSNumber numberWithInt:to],		@"Last",
//								  [NSNumber numberWithInt:offset],	@"Offset",
//								  nil];
//			
//			[offsets addObject:dict];
//		}
//		
//		[text release];
	}
	return self;
}

- (NSDictionary *)rangeWithCharacter:(unichar)character
{
	for (NSDictionary *dict in offsets)
	{
		if ([[dict objectForKey:@"First"] intValue] <= character && [[dict objectForKey:@"Last"] intValue] >= character)
		{
			return dict;
		}
	}
	return nil;
}

- (NSString *)unicodeCharacter:(unichar)cid
{
    NSString *result = [NSString stringWithFormat: @"%C", cid];
	NSDictionary *dict = [self rangeWithCharacter:cid];
    if (dict)
    {
        NSUInteger internalOffset = cid - [[dict objectForKey:@"First"] intValue];
        result = [NSString stringWithFormat: @"%C", [[dict objectForKey:@"Offset"] intValue] + internalOffset];
    }
    else if (chars)
    {
        NSNumber *fromChar = [NSNumber numberWithInt: cid];
        NSObject *to = [chars objectForKey: fromChar];
        if ([to isKindOfClass: [NSNumber class]]) {
            NSNumber *toChar = [chars objectForKey: fromChar];
            result = [NSString stringWithFormat: @"%C", [toChar intValue]];
        } else if ([to isKindOfClass: [NSArray class]]) {
            NSArray *toArray = (NSArray *)to;
            NSNumber *nextChar;
            NSMutableString *temp = [[NSMutableString alloc] initWithCapacity: [toArray count]];
            for (int i = 0; i < [toArray count]; i++) {
                nextChar = [toArray objectAtIndex: i];
                [temp appendFormat: @"%C", [nextChar intValue]];                
            }
            result = [NSString stringWithString: temp];
            [temp release];
        }
    }
    return result;
}

- (void)dealloc
{
	[offsets release];
	[super dealloc];
}

@end

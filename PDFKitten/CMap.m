#import "CMap.h"
#import "TrueTypeFont.h"

static NSSet *operators;

static NSString *kCodeSpaceRangeStart = @"begincodespacerange";
static NSString *kCodeSpaceRangeEnd = @"endcodespacerange";

static NSString *kBFCharBegin = @"beginbfchar";
static NSString *kBFCharEnd = @"endbfchar";

static NSString *kBFRangeBegin = @"beginbfrange";
static NSString *kBFRangeEnd = @"endbfrange";

@implementation CMap


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

- (BOOL)isOperator:(NSString *)token
{
	[token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return [operators containsObject:token];
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
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanHexInt:&to];
        
        NSNumber *fromNumber = [NSNumber numberWithInt:from];
        NSNumber *toNumber = [NSNumber numberWithInt:to];
        [chars setObject:toNumber  forKey:fromNumber];
    }
}


/**!
 *	
 *
 *
 */
- (void)scanCMap:(NSScanner *)scanner
{
	NSMutableArray *rangeDelimiters = [NSMutableArray array];

	
	NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
	
	while (![scanner isAtEnd])
	{

		NSString *word = nil;
		[scanner scanUpToCharactersFromSet:set intoString:&word];
		if ([self isOperator:word])
		{
			if ([word isEqualToString:kCodeSpaceRangeStart])
			{
				NSString *buffer = nil;
				
				[scanner scanUpToCharactersFromSet:set intoString:&word];
				word = [word stringByTrimmingCharactersInSet:set];
				while (![word isEqualToString:kCodeSpaceRangeEnd])
				{
					// Keep scanning values until end token
					if (!buffer)
					{
						buffer = word;
					}
					else
					{
						NSArray *arr = [NSArray arrayWithObjects:
										[buffer stringByTrimmingCharactersInSet:tagSet], 
										[word stringByTrimmingCharactersInSet:tagSet], nil];
						[rangeDelimiters addObject:arr];
						buffer = nil;
					}
					[scanner scanUpToCharactersFromSet:set intoString:&word];
				}
				NSLog(@"Ranges: %@", rangeDelimiters);
			}
//			else if ([word isEqualToString:@"beginbfchar"])
//			{
//				...
//			}
//			else if ([word isEqualToString:@"beginbfrange"])
//			{
//				...	
//			}
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
		operators = [[NSSet alloc] initWithObjects:
								   @"begincodespacerange",
								   @"beginbfchar", 
								   @"beginbfrange", nil];

		NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
		
		NSArray *docss = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path = [[docss lastObject] stringByAppendingPathComponent:@"CMap"];
		[data writeToFile:path atomically:YES];
		
		NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[data release];
		
		NSLog(@"=== CMAP ===");
//		NSLog(@"%@", text);

		NSScanner *scanner = [NSScanner scannerWithString:text];

		[self scanCMap:scanner];
//		[self scanning:text];
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

- (unichar)unicodeCharacter:(unichar)cid
{
	NSDictionary *dict = [self rangeWithCharacter:cid];
    if (dict)
    {
        NSUInteger internalOffset = cid - [[dict objectForKey:@"First"] intValue];
        return [[dict objectForKey:@"Offset"] intValue] + internalOffset;
    }
    else if (chars)
    {
        NSNumber *fromChar = [NSNumber numberWithInt: cid];
        NSNumber *toChar = [chars objectForKey: fromChar];
        return [toChar intValue];
    }
    return cid;
}

- (void)dealloc
{
	[offsets release];
	[super dealloc];
}

@end

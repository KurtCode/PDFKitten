#import "CMap.h"
#import "TrueTypeFont.h"

static NSString *kCodeSpaceRangeStart = @"begincodespacerange";
static NSString *kCodeSpaceRangeEnd = @"endcodespacerange";

static NSString *kBFCharBegin = @"beginbfchar";
static NSString *kBFCharEnd = @"endbfchar";

static NSString *kBFRangeBegin = @"beginbfrange";
static NSString *kBFRangeEnd = @"endbfrange";

static NSSet *sharedOperators = nil;


const Operator OperatorNone = {nil, nil, nil};

inline Operator OperatorMake(NSString *tag, NSString *start, NSString *end) {
	Operator operator;
	operator.label = tag;
	operator.start = start;
	operator.end = end;
	return operator;
};

inline BOOL OperatorIsEmpty(Operator op)
{
	return (op.label == nil 
			&& op.start == nil
			&& op.end == nil);
}

inline NSString *OperatorGetTag(Operator op)
{
	return op.label;
}

static int numberOfKnownOperators = 1;
static Operator knownOperators[] = {
	{@"CodeSpaceRange", @"begincodespacerange", @"endcodespacerange"}
};


@implementation CMap

- (NSSet *)operators
{
	@synchronized (self)
	{
		if (!sharedOperators)
		{
			sharedOperators = [[NSSet alloc] initWithObjects:
							   kCodeSpaceRangeStart,
							   kBFCharBegin, 
							   kBFRangeBegin, nil];
		}
		return sharedOperators;
	}
}

- (NSString *)endToken:(NSString *)str
{
	if (kCodeSpaceRangeStart)
	{
		return kCodeSpaceRangeEnd;
	}
	return @"";
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

- (Operator)isOperatorStart:(NSString *)string
{
	for (int i = 0; i < numberOfKnownOperators; i++)
	{
		Operator op = knownOperators[i];
		if ([string isEqualToString:op.start])
		{
			return op;
		}
	}
	return OperatorNone;
}

- (BOOL)isOperator:(NSString *)token
{
	[token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return [self.operators containsObject:token];
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

- (void)addCodeSpaceRangeFrom:(unsigned int)low to:(unsigned int)high
{
	static NSString *rangesLabel = @"Ranges";
	NSValue *range = [NSValue valueWithRange:NSMakeRange(low, (high - low))];
	
	NSMutableArray *ranges = [self.context valueForKey:rangesLabel];
	if (!ranges)
	{
		ranges = [NSMutableArray array];
		[self.context setValue:ranges forKey:rangesLabel];
	}
	[ranges addObject:range];
}

/**!
 * Code space ranges are pairs of hex numbers
 */
- (void)handleCodeSpaceRange:(NSString *)string
{
	NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
	string = [string stringByTrimmingCharactersInSet:tagSet];
	
	unsigned int numericValue;
	if (![[NSScanner scannerWithString:string] scanHexInt:&numericValue]) return;
	
	static NSString *rangeLowerBound = @"MIN";
	
	if ([self.context objectForKey:rangeLowerBound] != nil)
	{
		// Assemble range from stored, current values
		unsigned int lowerBound = [[self.context valueForKey:rangeLowerBound] intValue];
		[self addCodeSpaceRangeFrom:lowerBound	to:numericValue];
		return;
	}
	
	[self.context setValue:[NSNumber numberWithInt:numericValue] forKey:rangeLowerBound];
}

- (SEL)selectorForOperator:(NSString *)operator
{
	if (operator == kCodeSpaceRangeStart)
	{
		currentHandler = @selector(handleCodeSpaceRange:);
	}
}

/**!
 *	
 *
 *
 */
- (void)scanCMap:(NSScanner *)scanner
{
	NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	NSInteger numericValue = 0;
	
	NSString *word = nil;
	while (![scanner isAtEnd])
	{
		// Scan one word
		[scanner scanUpToCharactersFromSet:set intoString:&word];

		// Check for comment characher
		int commentPosition = [word rangeOfString:@"%"].location;
		if (commentPosition >= 0)
		{
			// If comment, trim and scan to EOL
			word = [word substringToIndex:commentPosition];
			[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
		}
		
		numericValue = [word integerValue];
		if (numericValue > 0 && numericValue != NSIntegerMax && numericValue != NSIntegerMin)
		{
		}
		
		Operator op = [self isOperatorStart:word];
		if ([word isEqualToString:currentOperator.end])
		{
			// End the current context
			currentOperator = OperatorNone;
			self.context = nil;
		}
		else if (!OperatorIsEmpty(op))
		{
			// Start a new context
			currentOperator = op;
			self.context = [NSMutableDictionary dictionary];
		}
		else if (currentHandler != nil)
		{
			// Send input to the current context
			[self performSelector:currentHandler withObject:word];
		}
	}
}

- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	if ((self = [super init]))
	{

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

@synthesize operators, context;
@end

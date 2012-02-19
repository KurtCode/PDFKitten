#import "CMap.h"

static NSSet *sharedOperators = nil;
static NSCharacterSet *sharedTagSet = nil;
static NSCharacterSet *sharedTokenDelimimerSet = nil;
static NSString *kOperatorKey = @"CurrentOperator";

NSValue *rangeValue(unsigned int from, unsigned int to)
{
	return [NSValue valueWithRange:NSMakeRange(from, to-from)];
}

@implementation Operator

+ (Operator *)operatorWithStart:(NSString *)start end:(NSString *)end handler:(SEL)handler
{
	Operator *op = [[[Operator alloc] init] autorelease];
	op.start = start;
	op.end = end;
	op.handler = handler;
	return op;
}

@synthesize start, end, handler;
@end

@interface CMap ()
- (void)handleCodeSpaceRange:(NSString *)string;
- (void)handleCharacter:(NSString *)string;
- (void)handleCharacterRange:(NSString *)string;
- (void)scanCMap:(NSString *)string;
@property (readonly) NSCharacterSet *tokenDelimiterSet;
@property (nonatomic, retain) NSMutableDictionary *context;
@property (nonatomic, readonly) NSCharacterSet *tagSet;
@property (nonatomic, readonly) NSSet *operators;
@end

@implementation CMap

- (id)initWithString:(NSString *)string
{
	if ((self = [super init]))
	{
		[self scanCMap:string];
	}
	return self;
}

- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	NSData *data = [(NSData *) CGPDFStreamCopyData(stream, nil) autorelease];
	NSString *text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return [self initWithString:text];
}

- (BOOL)isInCodeSpaceRange:(unichar)cid
{
	for (NSValue *rangeValue in self.codeSpaceRanges)
	{
		NSRange range = [rangeValue rangeValue];
		if (cid >= range.location && cid <= NSMaxRange(range))
		{
			return YES;
		}
	}
	return NO;
}

/**!
 * Returns the unicode value mapped by the given character ID
 */
- (unichar)unicodeCharacter:(unichar)cid
{
	if (![self isInCodeSpaceRange:cid]) return 0;

	NSArray	*mappedRanges = [self.characterRangeMappings allKeys];
	for (NSValue *rangeValue in mappedRanges)
	{
		NSRange range = [rangeValue rangeValue];
		if (cid >= range.location && cid <= NSMaxRange(range))
		{
			NSNumber *offsetValue = [self.characterRangeMappings objectForKey:rangeValue];
			return cid + [offsetValue intValue];
		}
	}
	
	NSArray *mappedValues = [self.characterMappings allKeys];
	for (NSNumber *from in mappedValues)
	{
		if ([from intValue] == cid)
		{
			return [[self.characterMappings objectForKey:from] intValue];
		}
	}
	
	return (unichar) NSNotFound;
}

- (NSSet *)operators
{
	@synchronized (self)
	{
		if (!sharedOperators)
		{
			sharedOperators = [[NSMutableSet alloc] initWithObjects:
							   [Operator operatorWithStart:@"begincodespacerange" 
														end:@"endcodespacerange"
													handler:@selector(handleCodeSpaceRange:)],
							   [Operator operatorWithStart:@"beginbfchar" 
													   end:@"endbfchar" 
												   handler:@selector(handleCharacter:)],
							   [Operator operatorWithStart:@"beginbfrange" 
													   end:@"endbfrange" 
												   handler:@selector(handleCharacterRange:)],
			nil];
		}
		return sharedOperators;
	}
}

#pragma mark -
#pragma mark Scanner

- (Operator *)operatorWithStartingToken:(NSString *)token
{
	for (Operator *op in self.operators)
	{
		if ([op.start isEqualToString:token]) return op;
	}
	return nil;
}

/**!
 * Removes remainder of string after comment. Also advances scanner to start of next line.
 */
- (NSString *)stringByRemovingComment:(NSString *)token scanner:(NSScanner *)scanner
{
	// Check for comment characher
	static NSString *kLineCommentToken = @"%@";
	int commentPosition = [token rangeOfString:kLineCommentToken].location;
	if (commentPosition != NSNotFound)
	{
		// If comment, trim and scan to EOL
		token = [token substringToIndex:commentPosition];
		[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
	}
	return token;
}

/**!
 *
 */
- (void)scanCMap:(NSString *)string
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSString *token = nil;
	while (![scanner isAtEnd])
	{
		[scanner scanUpToCharactersFromSet:self.tokenDelimiterSet intoString:&token];
		[self stringByRemovingComment:token scanner:scanner];

		Operator *operator = [self operatorWithStartingToken:token];
		if (operator)
		{
			// Start a new context
			self.context = [NSMutableDictionary dictionaryWithObject:operator forKey:kOperatorKey];
		}
		else if (self.context)
		{
			operator = [self.context valueForKey:kOperatorKey];
			if ([token isEqualToString:operator.end])
			{
				// End the current context
				self.context = nil;
			}
			else
			{
				// Send input to the current context
				[self performSelector:operator.handler withObject:token];
			}
		}
	}
}


#pragma mark -
#pragma mark Parsing handlers

/**!
 * Trims tag characters from the argument string, and returns the parsed integer value of the string.
 *
 * @param tagString string representing a hexadecimal number, possibly within tags
 */
- (unsigned int)valueOfTag:(NSString *)tagString
{
	unsigned int numericValue = 0;
	tagString = [tagString stringByTrimmingCharactersInSet:self.tagSet];
	[[NSScanner scannerWithString:tagString] scanHexInt:&numericValue];
	return numericValue;
}

/**!
 * Code space ranges are pairs of hex numbers:
 *	<from> <to>
 */
- (void)handleCodeSpaceRange:(NSString *)string
{
	static NSString *rangeLowerBound = @"MIN";
	NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:string]];
	NSNumber *low = [self.context valueForKey:rangeLowerBound];

	if (!low)
	{
		[self.context setValue:value forKey:rangeLowerBound];
		return;
	}
	
	[self.codeSpaceRanges addObject:rangeValue([low intValue], [value intValue])];
	[self.context removeObjectForKey:rangeLowerBound];
}

/**!
 * Character mappings appear in pairs:
 *	<from> <to>
 */
- (void)handleCharacter:(NSString *)character
{
	NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:character]];
	static NSString *origin = @"Origin";
	NSNumber *from = [self.context valueForKey:origin];
	if (!from)
	{
		[self.context setValue:value forKey:origin];
		return;
	}
	[self.characterMappings setObject:value forKey:from];
	[self.context removeObjectForKey:origin];
}

/**!
 * Ranges appear on the triplet form:
 *	<from> <to> <offset>
 */
- (void)handleCharacterRange:(NSString *)token
{
	NSNumber *value = [NSNumber numberWithInt:[self valueOfTag:token]];
	static NSString *from = @"From";
	static NSString *to = @"To";
	NSNumber *fromValue = [self.context valueForKey:from];
	NSNumber *toValue = [self.context valueForKey:to];
	if (!fromValue)
	{
		[self.context setValue:value forKey:from];
		return;
	}
	else if (!toValue)
	{
		[self.context setValue:value forKey:to];
		return;
	}
	NSValue *range = rangeValue([fromValue intValue], [toValue intValue]);
	[self.characterRangeMappings setObject:value forKey:range];
	[self.context removeObjectForKey:from];
	[self.context removeObjectForKey:to];
}

#pragma mark -
#pragma mark Accessor methods

- (NSCharacterSet *)tagSet {
	if (!sharedTagSet) {
		sharedTagSet = [[NSCharacterSet characterSetWithCharactersInString:@"<>"] retain];
	}
	return sharedTagSet;
}

- (NSCharacterSet *)tokenDelimiterSet {
	if (!sharedTokenDelimimerSet) {
		sharedTokenDelimimerSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
	}
	return sharedTokenDelimimerSet;
}

- (NSMutableArray *)codeSpaceRanges {
	if (!codeSpaceRanges) {
		codeSpaceRanges = [[NSMutableArray alloc] init];
	}
	return codeSpaceRanges;
}

- (NSMutableDictionary *)characterMappings {
	if (!characterMappings) {
		characterMappings = [[NSMutableDictionary alloc] init];
	}
	return characterMappings;
}

- (NSMutableDictionary *)characterRangeMappings {
	if (!characterRangeMappings) {
		self.characterRangeMappings = [NSMutableDictionary dictionary];
	}
	return characterRangeMappings;
}

- (void)dealloc
{
	[offsets release];
	[codeSpaceRanges release];
	[super dealloc];
}

@synthesize operators, context;
@synthesize codeSpaceRanges, characterMappings, characterRangeMappings;
@end

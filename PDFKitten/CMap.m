#import "CMap.h"
#import "TrueTypeFont.h"

@implementation CMap


- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	if ((self = [super init]))
	{
		NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
		NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				
		NSScanner *scanner = [NSScanner scannerWithString:text];
		[scanner scanUpToString:@"beginbfrange" intoString:nil];
		[scanner scanUpToString:@"<" intoString:nil];
		NSString *characterRange = nil;
		[scanner scanUpToString:@"endbfrange" intoString:&characterRange];
		
		NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
		NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
		NSString *separatorString = @"><";

		offsets = [[NSMutableArray alloc] init];
		
		NSScanner *rangeScanner = [NSScanner scannerWithString:characterRange];
		while (![rangeScanner isAtEnd])
		{
			NSString *line = nil;
			[rangeScanner scanUpToCharactersFromSet:newLineSet intoString:&line];
			line = [line stringByTrimmingCharactersInSet:tagSet];
			NSArray *parts = [line componentsSeparatedByString:separatorString];
			if ([parts count] < 3) continue;
			
			NSUInteger from, to, offset;
			NSScanner *scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
			[scanner scanHexInt:&from];
			
			scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
			[scanner scanHexInt:&to];
			
			scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
			[scanner scanHexInt:&offset];
			
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:from],	@"First",
								  [NSNumber numberWithInt:to],		@"Last",
								  [NSNumber numberWithInt:offset],	@"Offset",
								  nil];
			
			[offsets addObject:dict];
		}
		
		[data release];
		[text release];
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

- (unichar)characterWithCID:(unichar)cid
{
	NSDictionary *dict = [self rangeWithCharacter:cid];
	NSUInteger internalOffset = cid - [[dict objectForKey:@"First"] intValue];
	return [[dict objectForKey:@"Offset"] intValue] + internalOffset;
}

- (void)dealloc
{
	[offsets release];
	[super dealloc];
}

@end

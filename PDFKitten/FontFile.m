#import "FontFile.h"

#define kHeaderLength 6

static NSDictionary *charactersByName = nil;

@implementation FontFile

- (id)initWithContentsOfURL:(NSURL *)url
{
	return [self initWithData:[NSData dataWithContentsOfURL:url]];
}

- (id)initWithData:(NSData *)someData
{
	if ((self = [super init]))
	{
		if (!someData)
		{
			[self release];
			return nil;
		}
		data = [someData retain];
		NSScanner *scanner = [NSScanner scannerWithString:self.text];
		NSCharacterSet *delimiterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
		
		names = [NSMutableDictionary dictionary];
		NSString *buffer;
		while (![scanner isAtEnd])
		{
			if (![scanner scanUpToCharactersFromSet:delimiterSet intoString:&buffer]) break;
			
			if ([buffer hasPrefix:@"%"])
			{
				[scanner scanUpToCharactersFromSet:newlineCharacterSet intoString:nil];
				continue;
			}
			
			if ([buffer isEqualToString:@"dup"])
			{
				int code;
				NSString *name;
				[scanner scanInt:&code];
				[scanner scanUpToCharactersFromSet:delimiterSet intoString:&name];
				if (name) [names setObject:name forKey:[NSNumber numberWithInt:code]];
			}
		}
	}
	return self;
}

+ (unichar)characterByName:(NSString *)name
{
	if (!charactersByName)
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 

									 [NSNumber numberWithInt:0xfb00], @"/ff",
									 [NSNumber numberWithInt:0xfb01], @"/fi",
									 [NSNumber numberWithInt:0xfb02], @"/fl",
									 [NSNumber numberWithInt:0xfb04], @"/ffl",
									 
									 [NSNumber numberWithInt:0x0054], @"/T",
									 [NSNumber numberWithInt:0x0061], @"/a",
									 [NSNumber numberWithInt:0x0063], @"/c",
									 [NSNumber numberWithInt:0x0065], @"/e",
									 [NSNumber numberWithInt:0x0068], @"/h",
									 [NSNumber numberWithInt:0x0069], @"/i",
									 [NSNumber numberWithInt:0x006c], @"/l",
									 [NSNumber numberWithInt:0x006e], @"/n",
									 [NSNumber numberWithInt:0x006f], @"/o",
									 [NSNumber numberWithInt:0x0031], @"/one",
									 [NSNumber numberWithInt:0x002e], @"/period",
									 [NSNumber numberWithInt:0x0073], @"/s",
									 [NSNumber numberWithInt:0x0074], @"/t",
									 [NSNumber numberWithInt:0x0075], @"/u",
									 [NSNumber numberWithInt:0x0076], @"/v",
									 [NSNumber numberWithInt:0x0079], @"/y",
									 nil];
		
		charactersByName = dict;
	}
	
	return [[charactersByName objectForKey:name] intValue];
}

- (NSString *)stringWithCode:(int)code
{
	static NSString *singleUnicodeCharFormat = @"%C";
	NSString *characterName = [names objectForKey:[NSNumber numberWithInt:code]];
	unichar unicodeValue = [FontFile characterByName:characterName];
    if (!unicodeValue) unicodeValue = code;
	return [NSString stringWithFormat:singleUnicodeCharFormat, unicodeValue];
}

- (NSString *)text
{
	if (!text)
	{
		// ASCII segment length (little endian)
		unsigned char *bytes = (uint8_t *) [self.data bytes];
		if (bytes[0] == 0x80)
		{
			asciiTextLength = bytes[2] | bytes[3] << 8 | bytes[4] << 16 | bytes[5] << 24;
			NSData *textData = [[NSData alloc] initWithBytes:bytes+kHeaderLength length:asciiTextLength];
			text = [[NSString alloc] initWithData:textData encoding:NSASCIIStringEncoding];
			[textData release];
		}
		else
		{
			text = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
		}
	}
	return text;
}

- (void)dealloc
{
	[text release];
	[data release];
	[super dealloc];
}

@synthesize data, text, names;
@end

#import "KittenTest.h"
#import "Scanner.h"
#import <QuartzCore/QuartzCore.h>
#import "FontFile.h"

@implementation KittenTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testKurtTheCat
{
	static NSString *keyword = @"kurt";
	NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"Kurt the Cat" ofType:@"pdf"];
	NSLog(@"Scanning for %@", keyword);
	Scanner *scanner = [[Scanner alloc] initWithContentsOfFile:pdfPath];
	[scanner setKeyword:keyword];
	[scanner scanDocumentPage:1];
	NSArray *selections = [scanner selections];
	NSLog(@"Found %d occurrances", [selections count]);
}

- (void)testParseFontFile
{
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"cmr10" withExtension:@"pfb"];
	FontFile *ff = [[FontFile alloc] initWithContentsOfURL:url];
	NSLog(@"ASCII length: %d", [[ff text] length]);
	NSLog(@"%@", [ff text]);
	
	NSLog(@"=== Ligatures");
	NSLog(@"FF: %@", [ff stringWithCode:0x0b]);
	NSLog(@"FI: %@", [ff stringWithCode:0x0c]);
	NSLog(@"FL: %@", [ff stringWithCode:0x0d]);
	NSLog(@"FFL: %@", [ff stringWithCode:0x0f]);
}

- (void)testLigatureExpander
{

	NSLog(@"=== Ligatures");
	
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ligatures" withExtension:@"pdf"];
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);

	Scanner *scanner = [[Scanner alloc] initWithDocument:doc];
	[scanner setKeyword:@"fish"];
	[scanner scanDocumentPage:1];

	NSLog(@"%@", [[scanner content] dataUsingEncoding:NSUTF8StringEncoding]);
	
	CGPDFDocumentRelease(doc);
}

- (void)testCMap
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"cmap"];
	NSString *cmapText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	CMap *cmap = [[CMap alloc] initWithString:cmapText];
	
	NSLog(@"================");
	NSLog(@"CMAP CONTENTS");
	NSLog(@"%@", [cmap codeSpaceRanges]);
	NSLog(@"%@", [cmap characterMappings]);
	NSLog(@"%@", [cmap characterRangeMappings]);

	NSLog(@"================");
	NSLog(@"TESTING EXPECTED VALUES");
	NSLog(@"%d => %d (%d)", 138, [cmap unicodeCharacter:138], 315);
	NSLog(@"%d => %d (%d)", 1, [cmap unicodeCharacter:1], 728);
	NSLog(@"%d => %d (%d)", 2, [cmap unicodeCharacter:2], 711);
	NSLog(@"%d => %d (%d)", 2684, [cmap unicodeCharacter:2684], 31615);
	NSLog(@"================");

}

- (CGPDFDictionaryRef)fontDictionary
{
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"iTabloPDFPlusUserGuide" withExtension:@"pdf"];
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge void*) url);
	CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
	CGPDFDictionaryRef catalog = CGPDFPageGetDictionary(page);
	CGPDFDictionaryRef resources;
	CGPDFDictionaryGetDictionary(catalog, "Resources", &resources);
	CGPDFDictionaryRef fonts;
	CGPDFDictionaryGetDictionary(resources, "Font", &fonts);
	CGPDFDictionaryRef font;
	CGPDFDictionaryGetDictionary(fonts, "C2_0", &font);
	return font;
}

- (void)testFont
{
	CGPDFDictionaryRef fontDict = [self fontDictionary];
	Font *font = [Font fontWithDictionary:fontDict];
	NSLog(@"%@", font);
}

@end

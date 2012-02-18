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

- (void)testExample
{
//    STFail(@"Unit tests are not implemented yet in KittenTest");
	NSLog(@"Testing Kurt the PDF kitten!");
}

//- (void)testKurtTheCat
//{
//	static NSString *keyword = @"kurt";
//	NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"Kurt the Cat" ofType:@"pdf"];
//	NSLog(@"Scanning for %@", keyword);
//	Scanner *scanner = [[Scanner alloc] initWithContentsOfFile:pdfPath];
//	[scanner setKeyword:keyword];
//	[scanner scanDocumentPage:1];
//	NSArray *selections = [scanner selections];
//	NSLog(@"Found %d occurrances", [selections count]);
//}

//- (void)testParseFontFile
//{
//	NSURL *url = [[NSBundle mainBundle] URLForResource:@"cmr10" withExtension:@"pfb"];
//	FontFile *ff = [[FontFile alloc] initWithContentsOfURL:url];
//	NSLog(@"ASCII length: %d", [[ff text] length]);
//	NSLog(@"%@", [ff text]);
//	
//	[ff parse];
//	
//	
//	NSLog(@"=== Ligatures");
//	NSLog(@"FF: %@", [ff stringWithCode:0x0b]);
//	NSLog(@"FI: %@", [ff stringWithCode:0x0c]);
//	NSLog(@"FL: %@", [ff stringWithCode:0x0d]);
//	NSLog(@"FFL: %@", [ff stringWithCode:0x0f]);
//}

- (void)testLigatureExpander
{
	NSLog(@"=== Ligatures");
	
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ligatures" withExtension:@"pdf"];
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);

	Scanner *scanner = [[Scanner alloc] initWithDocument:doc];
	[scanner setKeyword:@"fish"];
	[scanner scanDocumentPage:1];

	NSLog(@"%@", [scanner content]);
	
	CGPDFDocumentRelease(doc);
}

@end

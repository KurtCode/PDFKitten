#import "KittenTest.h"
#import "Scanner.h"
#import <QuartzCore/QuartzCore.h>

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

//- (void)testExample
//{
////    STFail(@"Unit tests are not implemented yet in KittenTest");
//	NSLog(@"Testing Kurt the PDF kitten!");
//}
//
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
//
//- (void)testLigatureExpander
//{
//	NSLog(@"=== Ligatures");
//	
//	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ligatures" withExtension:@"pdf"];
//	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
//
//	Scanner *scanner = [[Scanner alloc] initWithDocument:doc];
//	[scanner setKeyword:@"fish"];
//	[scanner scanDocumentPage:1];
//
//	NSLog(@"%@", [[scanner content] dataUsingEncoding:NSUTF8StringEncoding]);
//	
//	CGPDFDocumentRelease(doc);
//}

- (void)testCMap
{
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"iTabloPDFPlusUserGuide" withExtension:@"pdf"];
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
	Scanner *scanner = [[Scanner alloc] initWithDocument:doc];
	
	[scanner setKeyword:@"apa"];
	[scanner scanDocumentPage:2];

	for (NSString *name in [scanner.fontCollection names])
	{
		Font *font = [scanner.fontCollection fontNamed:name];
	 	CMap *cmap = [font toUnicode];
	}
}

@end

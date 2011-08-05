#import "RootViewController.h"
#import "PDFPage.h"

@interface RootViewController ()
- (CGPDFDocumentRef)newPDFDocumentWithPath:(NSString *)path;
@end


@implementation RootViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		document = [self newPDFDocumentWithPath:self.documentPath];
	}
	return self;
}

- (NSInteger)numberOfPagesInPageView:(PageView *)pageView
{
	return CGPDFDocumentGetNumberOfPages(document);
}

- (Page *)pageView:(PageView *)aPageView viewForPage:(NSInteger)aPage
{
	PDFPage *page = (PDFPage *) [aPageView dequeueRecycledPage];
	if (!page)
	{
		page = [[[PDFPage alloc] initWithFrame:CGRectZero] autorelease];
	}
	page.pageNumber = aPage;
	[(PDFContentView *)page.contentView setPage:CGPDFDocumentGetPage(document, aPage+1)];
	
	return page;
}

- (CGPDFDocumentRef)newPDFDocumentWithPath:(NSString *)path
{
	NSURL *pdfURL = [NSURL fileURLWithPath:path];
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	return doc;
}

- (NSString *)documentPath
{
	return [[NSBundle mainBundle] pathForResource:@"Kurt the Cat" ofType:@"pdf"];
}

@end

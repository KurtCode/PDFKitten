#import "RootViewController.h"  
#import "PDFPage.h"
#import "DropboxSDK.h"

@implementation RootViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
        NSURL *pdfURL = [NSURL fileURLWithPath:self.documentPath];
        document = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Ask user to connect Dropbox account
	DBLoginController *loginController = [[DBLoginController new] autorelease];
	[loginController presentFromController:self];
}

#pragma mark PageViewDelegate

/* The number of pages in the current PDF document */
- (NSInteger)numberOfPagesInPageView:(PageView *)pageView
{
	return CGPDFDocumentGetNumberOfPages(document);
}

// TODO: Assign page to either the page or its content view, not both.

/* Page view object for the requested page */
- (Page *)pageView:(PageView *)aPageView viewForPage:(NSInteger)pageNumber
{
	PDFPage *page = (PDFPage *) [aPageView dequeueRecycledPage];
	if (!page)
	{
		page = [[[PDFPage alloc] initWithFrame:CGRectZero] autorelease];
	}
    
	page.pageNumber = pageNumber;
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, pageNumber + 1); // PDF document page numbers are 1-based
    [page setPage:pdfPage];
	[(PDFContentView *)page.contentView setPage:pdfPage];
	return page;
}

// TODO: add user interface for choosing document

- (NSString *)documentPath
{
    // DEBUG: for now, always load Kurt the Cat
	return [[NSBundle mainBundle] pathForResource:@"Kurt the Cat" ofType:@"pdf"];
}


#pragma mark Memory Management

- (void)dealloc
{
    CGPDFDocumentRelease(document);
    [super dealloc];
}

@end

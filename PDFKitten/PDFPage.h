#import "Page.h"


@interface PDFContentView : PageContentView {
	CGPDFPageRef pdfPage;
}

#pragma mark

- (void)setPage:(CGPDFPageRef)page;

@end

#pragma mark

@interface PDFPage : Page {
}

#pragma mark

- (void)setPage:(CGPDFPageRef)page;

@end

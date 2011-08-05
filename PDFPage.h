#import "Page.h"


@interface PDFContentView : PageContentView {
	CGPDFPageRef pdfPage;
}
- (void)setPage:(CGPDFPageRef)page;

@end

@interface PDFPage : Page {
    CGPDFPageRef pdfPage;
}
- (void)setPage:(CGPDFPageRef)page;

@end

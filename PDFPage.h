#import "Page.h"


@interface PDFContentView : UIView {
	CGPDFPageRef pdfPage;
}
- (void)setPage:(CGPDFPageRef)page;

@end

@interface PDFPage : Page {
}

@end

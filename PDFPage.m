#import "PDFPage.h"


@implementation PDFContentView

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, rect);
	CGContextTranslateCTM(ctx, 0.0, rect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	NSInteger rotationAngle = CGPDFPageGetRotationAngle(pdfPage);
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, rect, -rotationAngle, YES);
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, pdfPage);
}

- (void)setPage:(CGPDFPageRef)page
{
    CGPDFPageRelease(pdfPage);
	pdfPage = CGPDFPageRetain(page);
}


@end

@implementation PDFPage

- (void)setPage:(CGPDFPageRef)page
{
    CGPDFPageRelease(pdfPage);
    pdfPage = CGPDFPageRetain(page);

    CGRect rect = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    self.contentView.frame = rect;
}

- (UIView *)contentView
{
	if (!contentView)
	{
		contentView = [[PDFContentView alloc] initWithFrame:CGRectZero];
	}
	return contentView;
}

@end

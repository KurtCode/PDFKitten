#import "PDFPage.h"


@implementation PDFContentView

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGRect cropBox = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
//	CGFloat hScale = cropBox.size.width / rect.size.width;
//	CGFloat vScale = cropBox.size.height / rect.size.height;
//	CGFloat scale = MAX(hScale, vScale);
	
	CGContextTranslateCTM(ctx, 0.0, rect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	
	NSInteger rotationAngle = CGPDFPageGetRotationAngle(pdfPage);
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFMediaBox, rect, -rotationAngle, true);
	CGContextConcatCTM(ctx, transform);
	
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, cropBox);
	
	CGContextDrawPDFPage(ctx, pdfPage);
}

- (void)setPage:(CGPDFPageRef)page
{
	pdfPage = CGPDFPageRetain(page);
}


@end

@implementation PDFPage


- (UIView *)contentView
{
	if (!contentView)
	{
		contentView = [[PDFContentView alloc] initWithFrame:CGRectZero];
	}
	return contentView;
}

@end

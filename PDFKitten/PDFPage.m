#import "PDFPage.h"
#import "Scanner.h"

@implementation PDFContentView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark PDF drawing

/* Draw the PDFPage to the content view */
- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
	CGContextTranslateCTM(ctx, 0.0, rect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
    
    // Transform coordinate system to match PDF
	NSInteger rotationAngle = CGPDFPageGetRotationAngle(pdfPage);
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, rect, -rotationAngle, YES);
	CGContextConcatCTM(ctx, transform);

    // Draw page
	CGContextDrawPDFPage(ctx, pdfPage);
    
    // Search for keyword, if set
    
    if (self.keyword)
    {
        Scanner *scanner = [[[Scanner alloc] init] autorelease];
        [scanner setKeyword:self.keyword];
        [scanner scanPage:pdfPage];
        NSArray *selections = [scanner selections];
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5] CGColor]);
        
        for (Selection *s in selections)
        {
            CGContextSaveGState(ctx);
            CGContextConcatCTM(ctx, s.transform);
            CGContextFillRect(ctx, s.frame);
            CGContextRestoreGState(ctx);
        }
    }
}

/* Sets the current PDFPage object */
- (void)setPage:(CGPDFPageRef)page
{
    CGPDFPageRelease(pdfPage);
	pdfPage = CGPDFPageRetain(page);
}

#pragma mark Memory Management

- (void)dealloc
{
    CGPDFPageRelease(pdfPage);
    [super dealloc];
}

@synthesize keyword;
@end

#pragma mark -

@implementation PDFPage

#pragma mark -

/* Override implementation to return a PDFContentView */ 
- (UIView *)contentView
{
	if (!contentView)
	{
		contentView = [[PDFContentView alloc] initWithFrame:CGRectZero];
	}
	return contentView;
}

- (void)setPage:(CGPDFPageRef)page
{
    [(PDFContentView *)self.contentView setPage:page];
    // Also set the frame of the content view according to the page size
    CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    self.contentView.frame = rect;
}

- (void)setKeyword:(NSString *)string
{
    ((PDFContentView *)contentView).keyword = string;
}

- (NSString *)keyword
{
    return ((PDFContentView *)contentView).keyword;
}

@end

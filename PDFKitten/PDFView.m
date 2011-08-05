#import "PDFView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
	{
		self.layer.delegate = self;
    }
    return self;
}

- (void)setDocument:(CGPDFDocumentRef)document
{
	// Release the old document (if any) and
	// retain the new one to make sure it sticks around.
	CGPDFDocumentRelease(pdfDocument);
	pdfDocument = CGPDFDocumentRetain(document);
	
	// Remove all selections
	self.selections = nil;
	
	// Cause the view to redraw
	[self setNeedsDisplay];
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[self.layer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGPDFDocumentRef doc = CGPDFDocumentRetain(self.document);
	
	CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
	
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	
	cropBox.size.width *= 2;
	cropBox.size.height *= 2;
	
	UIGraphicsBeginImageContext(cropBox.size);
	CGContextRef otherContext = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(otherContext, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(otherContext, cropBox);
	
	// Transform the CTM compensating for flipped coordinate system
	CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
	CGContextTranslateCTM(otherContext, 0.0, cropBox.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextScaleCTM(otherContext, 2.0, -2.0);
	
	
	
	// Draw PDF (scaled to fit)
	CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, layer.bounds, 0, YES));
//	CGContextConcatCTM(otherContext, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, layer.bounds, 0, YES));
	CGContextDrawPDFPage(ctx, page);
	CGContextDrawPDFPage(otherContext, page);
	
	
	for (Selection *s in self.selections)
	{
		CGContextSaveGState(ctx);
		
		CGContextConcatCTM(ctx, [s transform]);
		CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
		CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
		CGContextFillRect(ctx, [s frame]);
		
		CGContextRestoreGState(ctx);

	
		CGContextSaveGState(otherContext);
		
		CGContextConcatCTM(otherContext, [s transform]);
		CGContextSetFillColorWithColor(otherContext, [[UIColor yellowColor] CGColor]);
		CGContextSetBlendMode(otherContext, kCGBlendModeMultiply);
		CGContextFillRect(otherContext, [s frame]);
		
		CGContextRestoreGState(otherContext);
	}
	
	CGPDFDocumentRelease(doc); doc = nil;
	
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	NSData *data = UIImagePNGRepresentation(image);

	NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[docs lastObject] stringByAppendingPathComponent:@"PNG"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	}
	[data writeToFile:[path stringByAppendingPathComponent:@"render.png"] atomically:YES];
	
	UIGraphicsEndImageContext();
}

- (void)setSelections:(NSArray *)array
{
	[selections release];
	selections = [array retain];
	[self setNeedsDisplay];
}

- (void)dealloc
{
	CGPDFDocumentRelease(pdfDocument);
	[selections release];
    [super dealloc];
}

@synthesize document = pdfDocument, selections;
@end

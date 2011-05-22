#import <UIKit/UIKit.h>

@class PDFPageView;

@interface PDFDocView : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIScrollView *pageView;
	CGPDFDocumentRef *pdfDocument;
	
	NSMutableSet *visiblePages;
	NSMutableSet *recycledPages;
}

@end

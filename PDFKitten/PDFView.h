#import <UIKit/UIKit.h>
#import "Selection.h"

@interface PDFView : UIView {
	CGPDFDocumentRef pdfDocument;
	NSArray *selections;
}

@property (nonatomic, retain) NSArray *selections;
@property (nonatomic, assign) CGPDFDocumentRef document;
@end

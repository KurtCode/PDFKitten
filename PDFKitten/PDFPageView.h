#import <Foundation/Foundation.h>


@interface PDFPageView : UIScrollView {
	NSUInteger index;
	
}

@property (nonatomic, assign) CGPDFPageRef page;
@property (nonatomic, assign) NSUInteger index;
@end

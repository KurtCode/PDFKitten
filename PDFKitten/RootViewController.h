#import "PageViewController.h"
#import "PageView.h"

@interface RootViewController : UIViewController <PageViewDelegate> {
	CGPDFDocumentRef document;
}

@property (nonatomic, readonly) NSString *documentPath;
@end

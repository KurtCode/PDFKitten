#import "PageViewController.h"

@interface RootViewController : PageViewController {
	CGPDFDocumentRef document;
}

@property (nonatomic, readonly) NSString *documentPath;
@end

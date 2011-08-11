#import "PageViewController.h"
#import "PageView.h"

@interface RootViewController : UIViewController <PageViewDelegate, UIPopoverControllerDelegate> {
	CGPDFDocumentRef document;
    UIPopoverController *libraryPopover;
	IBOutlet PageView *pageView;
}

@property (nonatomic, readonly) NSString *documentPath;
@end

#import "PageViewController.h"
#import "PageView.h"

@interface RootViewController : UIViewController <PageViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate> {
	CGPDFDocumentRef document;
    UIPopoverController *libraryPopover;
	IBOutlet PageView *pageView;
	IBOutlet UISearchBar *searchBar;
	NSString *keyword;
}

@property (nonatomic, readonly) NSString *documentPath;
@end

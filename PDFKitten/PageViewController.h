#import <UIKit/UIKit.h>
#import "PageView.h"

@interface PageViewController : UIViewController <PageViewDelegate> {
	IBOutlet PageView *pageView;
}

@property (nonatomic, readonly) PageView *pageView;

@end

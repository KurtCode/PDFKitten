#import <UIKit/UIKit.h>

@interface DocumentsView : UINavigationController <UITableViewDelegate, UITableViewDataSource> {
	UITableViewController *tableViewController;
	NSArray *documents;
	NSDictionary *urlsByName;
	
	id delegate;
}

@property (nonatomic, assign) id delegate;
@end

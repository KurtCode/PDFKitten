#import <UIKit/UIKit.h>

@interface DocumentsView : UINavigationController <UITableViewDelegate, UITableViewDataSource>
{
	UITableViewController *tableViewController;
	NSArray *documents;
	NSDictionary *urlsByName;
	
	__weak id delegate;
}

@property (nonatomic, weak) id delegate;

@end
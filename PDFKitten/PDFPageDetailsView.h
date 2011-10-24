#import <UIKit/UIKit.h>
#import "FontCollection.h"

@interface PDFPageDetailsView : UINavigationController <UITableViewDelegate, UITableViewDataSource> {
	FontCollection *fontCollection;
}

- (id)initWithFont:(FontCollection *)fontCollection;

@end

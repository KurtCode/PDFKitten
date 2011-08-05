#import <UIKit/UIKit.h>
#import "Page.h"

@class PageView;

@protocol PageViewDelegate <NSObject>

- (NSInteger)numberOfPagesInPageView:(PageView *)pageView;
- (Page *)pageView:(PageView *)pageView viewForPage:(NSInteger)page;

@optional

- (void)pageView:(PageView *)pageView didScrollToPage:(NSInteger)pageNumber;

@end


@interface PageView : UIScrollView <UIScrollViewDelegate> {
	NSInteger numberOfPages;
	NSMutableSet *visiblePages;
	NSMutableSet *recycledPages;
	id<PageViewDelegate> dataSource;
	
}

- (Page *)dequeueRecycledPage;
- (void)reloadData;
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) id<PageViewDelegate> dataSource;
@end

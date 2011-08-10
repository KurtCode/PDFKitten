#import <UIKit/UIKit.h>
#import "Page.h"

@class PageView;


@protocol PageViewDelegate <NSObject>

#pragma mark - Required

/* Asks the delegate how many pages are in the document */
- (NSInteger)numberOfPagesInPageView:(PageView *)pageView;

/* Asks the delegate for a page view object */
- (Page *)pageView:(PageView *)pageView viewForPage:(NSInteger)page;

#pragma mark Optional

@optional

/* Tells the delegate when the document stopped scrolling at a page */
- (void)pageView:(PageView *)pageView didScrollToPage:(NSInteger)pageNumber;

@end

#pragma mark

@interface PageView : UIScrollView <UIScrollViewDelegate> {
	NSInteger numberOfPages;
	NSMutableSet *visiblePages;
	NSMutableSet *recycledPages;
	IBOutlet id<PageViewDelegate> dataSource;
}

#pragma mark -

/* Returns a recycled page, or nil if none exist */
- (Page *)dequeueRecycledPage;

/* Causes the page view to reload pages */
- (void)reloadData;

/* Scroll to a specific page */
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

/* The page currently visible */
@property (nonatomic, assign) NSInteger page;

/* Data source for pages */
@property (nonatomic, assign) id<PageViewDelegate> dataSource;

@end

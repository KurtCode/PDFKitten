#import "PageView.h"
#import "PDFPage.h"
#import "PDFPageDetailsView.h"

@interface PageView ()
@property (nonatomic, retain) PDFPageDetailsView *detailViewController;
@end

@implementation PageView

#pragma mark - View layout

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		self.delegate = self;
		self.pagingEnabled = YES;
		recycledPages = [[NSMutableSet alloc] init];
		visiblePages = [[NSMutableSet alloc] init];
        
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (void)reloadData
{
	for (Page *p in visiblePages)
	{
		[p removeFromSuperview];
	}
	[recycledPages unionSet:visiblePages];
	[visiblePages removeAllObjects];
	[self setNeedsLayout];
}

/* True if the page with given index is showing */
- (BOOL)isShowingPageForIndex:(NSInteger)index
{
    for (Page *p in visiblePages)
    {
        if (p.pageNumber == index)
        {
            return YES;
        }
    }
    return NO;
}

- (void)layoutSubviews
{
	numberOfPages = [dataSource numberOfPagesInPageView:self];

	self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * numberOfPages, CGRectGetWidth(self.bounds));
	
	CGRect visibleBounds = self.bounds;
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN(numberOfPages-1, lastNeededPageIndex);
	
	for (Page *aPage in visiblePages)
	{
		if (aPage.pageNumber < firstNeededPageIndex || aPage.pageNumber > lastNeededPageIndex)
		{
			[recycledPages addObject:aPage];
			[aPage removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; i++)
	{
        if ([self isShowingPageForIndex:i]) continue;
		
		Page *aPage = [dataSource pageView:self viewForPage:i];
		CGRect rect = self.frame;
		rect.origin.y = 0;
		rect.origin.x = CGRectGetWidth(rect) * i;
		aPage.frame = rect;
		
        [visiblePages addObject:aPage];
		[aPage setNeedsDisplay];
        
		[self addSubview:aPage];
	}
}

- (UIView *)dequeueRecycledPage
{
	@synchronized (self)
	{
		UIView *p = [recycledPages anyObject];
		if (p)
		{
			[[p retain] autorelease];
			[recycledPages removeObject:p];
		}
		return p;
	}
}

- (Page *)pageAtIndex:(NSInteger)index
{
	NSSet *pages = [[visiblePages copy] autorelease];
	for (Page *p in pages)
	{
		if (p.pageNumber == index)
		{
			return p;
		}
	}
	return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self setNeedsLayout];
}

/* Animated scrolling did stop */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
	{
		[dataSource pageView:self didScrollToPage:self.page];
	}
}

/* User touch scrolling did stop */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
	{
		[dataSource pageView:self didScrollToPage:self.page];
	}
}


#pragma mark - Page numbers

/* Scrolls to the given page */
- (void)setPage:(NSInteger)aPage animated:(BOOL)animated
{
	CGRect rect = self.frame;
	rect.origin.x = CGRectGetWidth(self.frame) * aPage;
	[self scrollRectToVisible:rect animated:YES];
	if (!animated)
	{
		if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
		{
			[dataSource pageView:self didScrollToPage:self.page];
		}
	}
}

/* Scrolls to the given page */
- (void)setPage:(NSInteger)aPage
{
	[self setPage:aPage animated:YES];
}

/* Returns the current page number */
- (NSInteger)page
{
	CGFloat minimumVisibleX = CGRectGetMinX(self.bounds);
	return floorf(minimumVisibleX / CGRectGetWidth(self.frame));
}

- (void)setKeyword:(NSString *)str
{
	[keyword release];
	keyword = [str retain];
	for (PDFPage *p in visiblePages)
	{
		p.keyword = str;
		[p setNeedsDisplay];
	}	
}

/* Show detailed view when info button has been pressed */
- (void)detailedInfoButtonPressed:(UIButton *)sender
{
	if (![dataSource respondsToSelector:@selector(pageView:detailedViewForPage:)])
	{
		return;
	}
	
    self.detailViewController = [dataSource pageView:self detailedViewForPage:self.page];
    UIView *detailedView = [self.detailViewController view];
    
	Page *currentPage = nil;
	
	for (Page *p in visiblePages)
	{
		if (p.pageNumber == self.page)
		{
			currentPage = p;
			break;
		}
	}

	if (!currentPage) return;
	
	if (currentPage.detailedView)
	{
		[UIView transitionFromView:currentPage.detailedView toView:currentPage duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
		currentPage.detailedView = nil;
		return;
	}
	
	currentPage.detailedView = detailedView;
	detailedView.frame = currentPage.frame;
	[UIView transitionFromView:currentPage toView:detailedView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

#pragma mark - Memory Management

- (void)dealloc
{
    [detailedViewController release];
	[keyword release];
	[recycledPages release];
	[visiblePages release];
	[super dealloc];
}

@synthesize page, dataSource, keyword, detailViewController;
@end

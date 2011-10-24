#import "PageView.h"
#import "PDFPage.h"

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
    for (Page *page in visiblePages)
    {
        if (page.pageNumber == index)
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
	
	for (Page *page in visiblePages)
	{
		if (page.pageNumber < firstNeededPageIndex || page.pageNumber > lastNeededPageIndex)
		{
			[recycledPages addObject:page];
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; i++)
	{
        if ([self isShowingPageForIndex:i]) continue;
		
		Page *page = [dataSource pageView:self viewForPage:i];
		CGRect rect = self.frame;
		rect.origin.y = 0;
		rect.origin.x = CGRectGetWidth(rect) * i;
		page.frame = rect;
		
        [visiblePages addObject:page];
		[page setNeedsDisplay];
        
		[self addSubview:page];
	}
}

- (UIView *)dequeueRecycledPage
{
	@synchronized (self)
	{
		UIView *page = [recycledPages anyObject];
		if (page)
		{
			[[page retain] autorelease];
			[recycledPages removeObject:page];
		}
		return page;
	}
}

- (Page *)pageAtIndex:(NSInteger)index
{
	NSSet *pages = [[visiblePages copy] autorelease];
	for (Page *page in pages)
	{
		if (page.pageNumber == index)
		{
			return page;
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
- (void)setPage:(NSInteger)page animated:(BOOL)animated
{
	CGRect rect = self.frame;
	rect.origin.x = CGRectGetWidth(self.frame) * page;
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
- (void)setPage:(NSInteger)page
{
	[self setPage:page animated:YES];
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
	
	UIView *detailedView = [dataSource pageView:self detailedViewForPage:self.page];

	Page *page = nil;
	
	for (Page *p in visiblePages)
	{
		if (p.pageNumber == self.page)
		{
			page = p;
			break;
		}
	}

	if (!page) return;
	
	if (page.detailedView)
	{
		[UIView transitionFromView:page.detailedView toView:page duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
		page.detailedView = nil;
		return;
	}
	
	page.detailedView = detailedView;
	detailedView.frame = page.frame;
	[UIView transitionFromView:page toView:detailedView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[keyword release];
	[recycledPages release];
	[visiblePages release];
	[super dealloc];
}

@synthesize page, dataSource, keyword;
@end

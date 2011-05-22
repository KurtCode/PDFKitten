#import "PDFDocView.h"
#import "PDFPageView.h"

@interface PDFDocView ()
- (PDFPageView *)dequeueRecycledPage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)configurePage:(PDFPageView *)page forIndex:(NSUInteger)index;
- (void)tilePages;

@property (nonatomic, readonly) NSUInteger pageCount;
@end

@implementation PDFDocView

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self tilePages];
}

#pragma mark - View lifecycle

- (void)tilePages
{
	// Calculate visible pages
	CGRect visibleBounds = pageView.bounds;
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN(lastNeededPageIndex, self.pageCount-1);
	
	// Recycle pages that fell off the screen
	for (PDFPageView *page in visiblePages)
	{
		if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex)
		{
			[recycledPages addObject:page];
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add new pages
	for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++)
	{
		if ([self isDisplayingPageForIndex:index]) continue;
		
		PDFPageView *page = [self dequeueRecycledPage];
		if (!page)
		{
			page = [[[PDFPageView alloc] init] autorelease];
		}
		[self configurePage:page forIndex:index];
		[pageView addSubview:page];
		[visiblePages addObject:page];
	}
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
	CGRect scrollViewFrame = pageView.frame;
	scrollViewFrame.origin = CGPointMake(index*CGRectGetWidth(scrollViewFrame), 0);
	return scrollViewFrame;
}

- (void)configurePage:(PDFPageView *)page forIndex:(NSUInteger)index
{
	page.index = index;
	page.frame = [self frameForPageAtIndex:index];
	
	page.backgroundColor = (index == 0) ? [UIColor blueColor] : ((index == 1) ? [UIColor greenColor] : [UIColor yellowColor] );
}

- (PDFPageView *)dequeueRecycledPage
{
	PDFPageView *page = [recycledPages anyObject];
	if (page)
	{
		[[page retain] autorelease];
		[recycledPages removeObject:page];
	}
	return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	for (PDFPageView *page in visiblePages)
	{
		if (page.index == index) return YES;
	}
	return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	pageView.contentSize = CGSizeMake(CGRectGetWidth(pageView.bounds)*self.pageCount, CGRectGetHeight(pageView.bounds));
	
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	
	[self tilePages];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSUInteger)pageCount
{
	return 3;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
	[visiblePages release];
	[recycledPages release];
    [super dealloc];
}

@end

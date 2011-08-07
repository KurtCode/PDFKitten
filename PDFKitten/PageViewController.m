#import "PageViewController.h"

@implementation PageViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
	}
	return self;
}

- (NSInteger)numberOfPagesInPageView:(PageView *)pageView
{
	return 0;
}

- (Page *)pageView:(PageView *)pageView viewForPage:(NSInteger)page
{
	return nil;
}


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[pageView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.pageView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@synthesize pageView;
@end

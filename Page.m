#import "Page.h"


@implementation PageContentView

- (void)drawRect:(CGRect)rect
{
	
}

@end

@implementation Page

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		UIView *view = [self contentView];
		view.frame = frame;
		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentView = view;
		[self addSubview:view];
		
		self.delegate = self;
    }
    return self;
}


- (UIView *)contentView
{
	if (!contentView)
	{
		contentView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	return contentView;
}

#pragma mark - UIScrollView delegate

/* Make the content view center on screen when zoomed out */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	CGRect frame = self.contentView.frame;
	// Calculate how much of the content view is outside the screen
	CGSize totalInset = CGSizeMake(CGRectGetWidth(contentView.frame) - CGRectGetWidth(self.bounds), 
								   CGRectGetHeight(contentView.frame) - CGRectGetHeight(self.bounds));
	if (totalInset.width < 0)
	{
		frame.origin.x = totalInset.width / 2;
	}
	if (totalInset.height < 0)
	{
		frame.origin.y = totalInset.height / 2;
	}
	self.contentView.frame = frame;
}


@synthesize pageNumber, contentView;
@end

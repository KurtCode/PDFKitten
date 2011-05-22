//
//  DocumentView.m
//  PDFDemo
//
//  Created by Marcus Hedenström on 2011-04-24.
//  Copyright 2011 Chalmers Göteborg. All rights reserved.
//

#import "DocumentView.h"
#import "PageView.h"

@implementation DocumentView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)tilePages
{
//	CGRect visibleBounds = scrollView.bounds;
//	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
//	int lastNeededPageIndex  = floorf(CGRectGetMaxX(visibleBounds) / CGRectGetWidth(visibleBounds));
//	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self tilePages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

//
//  PDFDemoViewController.m
//  PDFDemo
//
//  Created by Marcus Hedenström on 2011-04-15.
//  Copyright 2011 Chalmers Göteborg. All rights reserved.
//

#import "PDFDemoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PDFDemoViewController ()
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, readonly) NSArray *files;
@end

@implementation PDFDemoViewController

- (void)dealloc
{
	[files release];
	[dimView release];
	[filename release];
	[pdfView release];
	[toolbar release];
	[backsideView release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.files count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *name = [[[self.files objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"pdf"];
	CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	[pdfView setDocument:pdfDocument];
	CGPDFDocumentRelease(pdfDocument); pdfDocument = nil;
	
	[popover dismissPopoverAnimated:YES];
	[popover release]; popover = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	cell.textLabel.text = [self.files objectAtIndex:indexPath.row];
	return cell;
}

- (IBAction)pickDocument:(id)sender
{
	UITableViewController *view = [[UITableViewController alloc] init];
	if (!popover)
	{
		popover = [[UIPopoverController alloc] initWithContentViewController:view];
		popover.popoverContentSize = CGSizeMake(320, 480);
	}
	view.tableView.delegate = self;
	view.tableView.dataSource = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	[view release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		self.filename = @"Kurt the Cat";
	}
	return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return pdfView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	pdfView.layer.contentsScale = scale;
	[pdfView setNeedsDisplay];
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
	CGSize boundsSize = scrollView.bounds.size;
	CGRect frameToCenter = pdfView.frame;

	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	else
		frameToCenter.origin.x = 0;
	
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	else
		frameToCenter.origin.y = 0;
	
	pdfView.frame = frameToCenter;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (!dimView)
	{
		dimView = [[UIView alloc] initWithFrame:self.view.frame];
		[dimView setBackgroundColor:[UIColor blackColor]];
		[dimView setAlpha:0.0];
		[pdfView addSubview:dimView];
	}
	
	NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:curve];
	[UIView setAnimationDuration:duration];
	[dimView setAlpha:0.5];
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:curve];
	[UIView setAnimationDuration:duration];
	[dimView setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	Scanner *scanner = [[Scanner alloc] initWithDocument:pdfView.document];
	[scanner setKeyword:[searchBar text]];
	[scanner scanPage:1];

	[pdfView setSelections:[scanner selections]];
	
	[scanner release]; scanner = nil;
	[searchBar resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Listen for the keyboard appearing on the screen
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// Load the PDF document into the view
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:self.filename withExtension:@"pdf"];
	CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	[pdfView setDocument:pdfDocument];
	CGPDFDocumentRelease(pdfDocument); pdfDocument = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Stop listening for keyboard notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
	// When view disappears, remove PDF to save memory
	[pdfView setDocument:nil];
}

- (IBAction)showInfo:(id)sender
{
	[UIView transitionFromView:pdfView toView:backsideView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
	[scrollView setZoomScale:1.0 animated:YES];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
	BOOL shouldHide = ![toolbar isHidden];
	
	[toolbar setHidden:shouldHide];
	[[UIApplication sharedApplication] setStatusBarHidden:shouldHide withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Set navigation bar title
//	toolbar.topItem.title = self.filename;
	
	// Set up PDF view single-tap recognizer
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
	[pdfView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release]; tapRecognizer = nil;
	
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
	[pdfView addGestureRecognizer:doubleTapRecognizer];
	[doubleTapRecognizer release];
}

- (void)viewDidUnload
{
	[pdfView release];
	pdfView = nil;
	[toolbar release];
	toolbar = nil;
	[backsideView release];
	backsideView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSArray *)files
{
	if (!files)
	{
	 	NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
		NSMutableArray *arr = [NSMutableArray array];
		for (NSString *s in paths)
		{
			[arr addObject:[[s lastPathComponent] stringByDeletingPathExtension]];
		}
		files = [arr retain];
	}
	return files;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@synthesize filename;
@end

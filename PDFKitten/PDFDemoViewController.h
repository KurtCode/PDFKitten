//
//  PDFDemoViewController.h
//  PDFDemo
//
//  Created by Marcus Hedenström on 2011-04-15.
//  Copyright 2011 Chalmers Göteborg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFView.h"
#import "Scanner.h"

@interface PDFDemoViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
	NSString *filename;
	IBOutlet UIToolbar *toolbar;
	IBOutlet PDFView *pdfView;
	IBOutlet UIView *backsideView;
	IBOutlet UIScrollView *scrollView;
	NSArray *files;
	UIView *dimView;
	UIPopoverController *popover;
}
- (IBAction)showInfo:(id)sender;
- (IBAction)pickDocument:(id)sender;

@end

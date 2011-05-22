//
//  PDFDemoAppDelegate.h
//  PDFDemo
//
//  Created by Marcus Hedenström on 2011-04-15.
//  Copyright 2011 Chalmers Göteborg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFDocView.h"

@class PDFDemoViewController;

@interface PDFDemoAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PDFDemoViewController *viewController;

@end

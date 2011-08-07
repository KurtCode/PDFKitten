#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface PDFKittenAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@end

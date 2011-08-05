#import <UIKit/UIKit.h>


@interface PageContentView : UIView {
}
@end

@interface Page : UIScrollView <UIScrollViewDelegate> {
	NSInteger pageNumber;
	UIView *contentView;
}
- (UIView *)contentView;

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) NSInteger pageNumber;
@end

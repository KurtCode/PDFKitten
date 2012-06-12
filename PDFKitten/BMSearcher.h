#import <Foundation/Foundation.h>

@interface BMSearcher : NSObject {
	NSString *pattern;
}

- (id)initWithPattern:(NSString *)str;

- (void)search:(NSString *)text;

@property (nonatomic, retain) NSString *pattern;
@end

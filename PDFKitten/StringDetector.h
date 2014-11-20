/**
 * A detector implementing a finite state machine with the goal of detecting a predefined keyword in a continuous stream
 * of characters. The user of a detector can append strings, and will receive a number of messages reflecting the
 * current state of the detector.
 */

#import <Foundation/Foundation.h>
#import "Font.h"
#import "StringDetectorDelegate.h"

@class StringDetector;

@interface StringDetector : NSObject {
	NSString *keyword;
	NSUInteger keywordPosition;
	NSMutableString *unicodeContent;
	__weak id<StringDetectorDelegate> delegate;
}

+ (StringDetector *)detectorWithKeyword:(NSString *)keyword delegate:(id<StringDetectorDelegate>)delegate;
- (id)initWithKeyword:(NSString *)needle;
- (void)setKeyword:(NSString *)kword;
- (void)reset;

- (NSString *)appendString:(NSString *)inputString;

@property (nonatomic, weak) id<StringDetectorDelegate> delegate;
@property (nonatomic, retain) NSMutableString *unicodeContent;

@end
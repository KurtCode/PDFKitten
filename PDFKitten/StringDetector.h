/**
 * A detector implementing a finite state machine with the goal of detecting a predefined keyword in a continuous stream
 * of characters. The user of a detector can append strings, and will receive a number of messages reflecting the
 * current state of the detector.
 */

#import <Foundation/Foundation.h>
#import "Font.h"

@class StringDetector;

@protocol StringDetectorDelegate <NSObject>

@optional

/* Tells the delegate that the first character of the needle was detected */
- (void)detector:(StringDetector *)detector didStartMatchingString:(NSString *)string;

/* Tells the delegate that the entire needle was detected */
- (void)detector:(StringDetector *)detector foundString:(NSString *)needle;

/* Tells the delegate that one character was scanned */
- (void)detector:(StringDetector *)detector didScanCharacter:(unichar)character;

@end


@interface StringDetector : NSObject {
	NSString *keyword;
	NSUInteger keywordPosition;
	NSMutableString *unicodeContent;
	id<StringDetectorDelegate> delegate;
}

/* Initialize with a given needle */
- (id)initWithKeyword:(NSString *)needle;

/* Feed more charachers into the state machine */
- (NSString *)appendPDFString:(CGPDFStringRef)string withFont:(Font *)font;

/* Reset the detector state */
- (void)reset;

@property (nonatomic, retain) NSString *keyword;
@property (nonatomic, assign) id<StringDetectorDelegate> delegate;
@property (nonatomic, readonly) NSString *unicodeContent;
@end

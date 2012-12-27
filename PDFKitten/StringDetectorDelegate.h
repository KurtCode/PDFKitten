#import <Foundation/Foundation.h>

@class StringDetector;

@protocol StringDetectorDelegate <NSObject>
@optional
- (void)detectorDidStartMatching:(StringDetector *)stringDetector;
- (void)detectorFoundString:(StringDetector *)detector;
- (void)detector:(StringDetector *)detector didScanCharacter:(unichar)character;
@end

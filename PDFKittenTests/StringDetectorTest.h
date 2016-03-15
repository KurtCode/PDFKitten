#import <XCTest/XCTest.h>
#import "StringDetector.h"

@interface StringDetectorTest : XCTestCase <StringDetectorDelegate> {
    int matchCount;
    int prefixCount;
    NSString *kurtStory;
    StringDetector *stringDetector;
}

@end

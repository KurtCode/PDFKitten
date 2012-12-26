#import <SenTestingKit/SenTestingKit.h>
#import "StringDetector.h"

@interface StringDetectorTest : SenTestCase <StringDetectorDelegate> {
    int matchCount;
    int prefixCount;
    NSString *kurtStory;
    StringDetector *stringDetector;
}

@end

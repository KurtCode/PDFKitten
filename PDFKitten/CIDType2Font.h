#import <Foundation/Foundation.h>
#import "CIDFont.h"

@interface CIDType2Font : CIDFont {
    NSData *cidGidMap;
}

@end

#import <Foundation/Foundation.h>
#import "CompositeFont.h"

@interface CIDFont : CompositeFont {
    BOOL identity;
}

@property (readonly, getter = isIdentity) BOOL identity;
@end

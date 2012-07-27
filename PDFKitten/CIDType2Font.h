#import <Foundation/Foundation.h>
#import "CompositeFont.h"

@interface CIDType2Font : CompositeFont {
	BOOL identity;
}

@property (nonatomic, readonly, getter = isIdentity) BOOL identity;
@end

/*
 *	A composite font is one of the following types:
 *		- Type0
 *		- CIDType0Font
 *		- CIDType2Font
 *
 *	Composite fonts have the following specific traits:
 *		- Default glyph width
 *
 */

#import <Foundation/Foundation.h>
#import "Font.h"

@interface CompositeFont : Font {
    CGFloat defaultWidth;
}

@property (nonatomic, assign) CGFloat defaultWidth;
@end

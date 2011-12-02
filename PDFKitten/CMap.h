#import <Foundation/Foundation.h>


@interface CMap : NSObject {
	NSMutableArray *offsets;
    NSMutableDictionary *chars;
}

/* Initialize with PDF stream containing a CMap */
- (id)initWithPDFStream:(CGPDFStreamRef)stream;

/* Unicode mapping for character ID */
- (NSString *)unicodeCharacter:(unichar)cid;

@end

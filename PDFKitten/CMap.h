#import <Foundation/Foundation.h>


@interface CMap : NSObject {
	NSMutableArray *offsets;
}

/* Initialize with PDF stream containing a CMap */
- (id)initWithPDFStream:(CGPDFStreamRef)stream;

/* Unicode mapping for character ID */
- (unichar)characterWithCID:(unichar)cid;

@end

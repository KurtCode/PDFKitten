#import <Foundation/Foundation.h>

typedef struct {
	NSString *label;
	NSString *start;
	NSString *end;
} Operator;


@interface CMap : NSObject {
	NSMutableArray *offsets;
    NSMutableDictionary *chars;
	NSMutableDictionary *context;
	SEL currentHandler;
	NSString *currentEndToken;
	

	Operator currentOperator;

	
	NSDictionary *codeSpaceRanges;
	
}

/* Initialize with PDF stream containing a CMap */
- (id)initWithPDFStream:(CGPDFStreamRef)stream;

/* Unicode mapping for character ID */
- (unichar)unicodeCharacter:(unichar)cid;

@property (nonatomic, readonly) NSSet *operators;
@property (nonatomic, retain) NSMutableDictionary *context;

@end

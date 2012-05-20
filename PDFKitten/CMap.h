#import <Foundation/Foundation.h>

extern NSValue *rangeValue(unsigned int from, unsigned int to);

@interface Operator : NSObject
+ (Operator *)operatorWithStart:(NSString *)start end:(NSString *)end handler:(SEL)handler;
@property (retain) NSString *start;
@property (retain) NSString *end;
@property SEL handler;
@end

@interface CMap : NSObject {
	NSMutableArray *offsets;
    NSMutableDictionary *chars;
	NSMutableDictionary *context;
	NSString *currentEndToken;

	/* CMap ranges */
	NSMutableArray *codeSpaceRanges;
	
	/* Character mappings */
	NSMutableDictionary *characterMappings;
	
	/* Character range mappings */
	NSMutableDictionary *characterRangeMappings;
}

/* Initialize with PDF stream containing a CMap */
- (id)initWithPDFStream:(CGPDFStreamRef)stream;

/* Initialize with a string representation of a CMap */
- (id)initWithString:(NSString *)string;

/* Unicode mapping for character ID */
- (unichar)unicodeCharacter:(unichar)cid;

@property (nonatomic, retain) NSMutableArray *codeSpaceRanges;
@property (nonatomic, retain) NSMutableDictionary *characterMappings;
@property (nonatomic, retain) NSMutableDictionary *characterRangeMappings;

@end

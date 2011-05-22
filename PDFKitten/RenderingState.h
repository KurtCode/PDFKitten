#import <Foundation/Foundation.h>
#import "Font.h"

@class Font;

@interface RenderingState : NSObject <NSCopying> {
	CGAffineTransform lineMatrix;
	CGAffineTransform textMatrix;
	CGAffineTransform ctm;
	CGFloat leading;
	CGFloat wordSpacing;
	CGFloat characterSpacing;
	CGFloat horizontalScaling;
	CGFloat textRise;
	Font *font;
	CGFloat fontSize;
}

/* Set the text matrix and (optionally) the line matrix */
- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace;

/* Transform the text matrix and (optionally) the line matrix */
- (void)translateTextPosition:(CGSize)size;

/* Move to start of next line, optionally with custom line height and indent, and optionally save line height */
- (void)newLineWithLineHeight:(CGFloat)lineHeight indent:(CGFloat)indent save:(BOOL)save;
- (void)newLineWithLineHeight:(CGFloat)lineHeight save:(BOOL)save;
- (void)newLine;


/* Matrixes */
@property (nonatomic, assign) CGAffineTransform lineMatrix;
@property (nonatomic, assign) CGAffineTransform textMatrix;
@property (nonatomic, assign) CGAffineTransform ctm;

/* Text size, spacing and scaling */
@property (nonatomic, assign) CGFloat characterSpacing;
@property (nonatomic, assign) CGFloat wordSpacing;
@property (nonatomic, assign) CGFloat leadning;
@property (nonatomic, assign) CGFloat textRise;
@property (nonatomic, assign) CGFloat horizontalScaling;

/* Font */
@property (nonatomic, retain) Font *font;
@property (nonatomic, assign) CGFloat fontSize;

@end


@interface RenderingStateStack : NSObject {
	NSMutableArray *stack;
}

- (RenderingState *)popRenderingState;
- (void)pushRenderingState:(RenderingState *)state;

@property (nonatomic, readonly) RenderingState *topRenderingState;
@end
#import <Foundation/Foundation.h>
#import "StringDetector.h"
#import "FontCollection.h"
#import "RenderingState.h"
#import "Selection.h"
#import "RenderingStateStack.h"

@interface Scanner : NSObject <StringDetectorDelegate> {
	CGPDFPageRef pdfPage;
	NSMutableArray *selections;
	
	StringDetector *stringDetector;
	FontCollection *fontCollection;
	RenderingStateStack *renderingStateStack;
	NSMutableString *content;
}

+ (Scanner *)scannerWithPage:(CGPDFPageRef)page;

- (NSArray *)select:(NSString *)keyword;

@property (nonatomic, readonly) RenderingState *renderingState;

@property (nonatomic, retain) RenderingStateStack *renderingStateStack;
@property (nonatomic, retain) FontCollection *fontCollection;
@property (nonatomic, retain) StringDetector *stringDetector;
@property (nonatomic, retain) NSMutableString *content;


@property (nonatomic, retain) NSMutableArray *selections;
@end

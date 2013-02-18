#import <Foundation/Foundation.h>

@class RenderingState;

@interface Selection : NSObject

+ (Selection *)selectionWithState:(RenderingState *)state;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) CGAffineTransform transform;

@property (nonatomic, copy) RenderingState *initialState;
@property (nonatomic, copy) RenderingState *finalState;

@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat ascent;
@end

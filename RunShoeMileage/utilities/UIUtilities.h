//
//  UIUtilities.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/26/14.
//
//

#import <Foundation/Foundation.h>

static const CGFloat lineXposition = 90.0;
static const CGFloat lineWidth = 2.0;

@interface UIUtilities : NSObject

+ (void)configureInputFieldBackgroundViews:(UIView *)view;
+ (void)setShoeCyclePatternedBackgroundOnView:(UIView *)view;
+ (UIView *)getDottedLineForFrame:(CGRect)frame color:(UIColor *)color;
+ (BOOL)isIphone4ScreenSize;

@end

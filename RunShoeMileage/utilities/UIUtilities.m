//
//  UIUtilities.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/26/14.
//
//

#import "UIUtilities.h"

@interface LineView:UIView

@property (nonatomic, strong) UIColor *lineColor;

@end

@implementation LineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    static const CGFloat dashPattern[] = {2.0};
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.bounds.size.width);
    CGContextSetLineDash(context, 0, dashPattern, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextDrawPath(context, kCGPathStroke);
}

@end


@implementation UIUtilities

+ (void)configureInputFieldBackgroundViews:(UIView *)view
{
    view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    view.layer.borderWidth = 1.0;
    view.layer.cornerRadius = 7.0;
    view.clipsToBounds = YES;
}

+ (void)setShoeCyclePatternedBackgroundOnView:(UIView *)view
{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"perfTile"]];
}

+ (UIView *)getDottedLineForFrame:(CGRect)frame color:(UIColor *)color
{
    LineView *lineView = [[LineView alloc] initWithFrame:frame];
    lineView.lineColor = color;
    return lineView;
}

+ (BOOL)isIphone4ScreenSize
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height < 500)
    {
        return YES;
    }
    return NO;
}

@end

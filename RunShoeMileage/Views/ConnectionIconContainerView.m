//
//  ConnectionIconContainerView.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/12/15.
//
//

#import "ConnectionIconContainerView.h"

const CGFloat iconDimension = 22;

@implementation ConnectionIconContainerView

- (void)drawRect:(CGRect)rect
{
    if ([self.iconsToDisplay count] > 0) {
        CGFloat spacing = self.bounds.size.width / [self.iconsToDisplay count];
        CGFloat centerSpacing = spacing / 2;
        [self.iconsToDisplay enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGFloat xCenter = (idx * spacing) + centerSpacing;
            view.center = CGPointMake(xCenter, self.bounds.size.height/2);
        }];
    }
}

- (void)setIconsToDisplay:(NSArray *)iconsToDisplay
{
    [_iconsToDisplay makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _iconsToDisplay = nil;
    [iconsToDisplay enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIView class]]) {
            if (view.bounds.size.width == iconDimension && view.bounds.size.height == iconDimension) {
                view.frame = CGRectMake(0, 0, iconDimension, iconDimension);
                [self addSubview:view];
            }
            else
            {
                NSString *errorMessage = [NSString stringWithFormat:@"All items in array must be of size %0.0f x %0.0f",iconDimension,iconDimension];
                NSCAssert(NO, errorMessage);
            }
        }
        else {
            NSCAssert(NO, @"All items in array must be a UIView or subclass thereof.");
        }
    }];
    _iconsToDisplay = [iconsToDisplay copy];
    [self setNeedsDisplay];
}

@end

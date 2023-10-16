//
//  UIView+Effects.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/12/15.
//
//

#import "UIView+Effects.h"

@implementation UIView (Effects)

- (void)pulseView
{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

@end

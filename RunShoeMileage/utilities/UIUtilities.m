//
//  UIUtilities.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 9/26/14.
//
//

#import "UIUtilities.h"

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
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_mamba"]];
}
@end

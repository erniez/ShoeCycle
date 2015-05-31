//
//  UIAlertController+CommonAlerts.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/18/15.
//
//

#import "UIAlertController+CommonAlerts.h"

@implementation UIAlertController (CommonAlerts)

+ (UIAlertController *)alertControllerWithOKButtonAndTitle:(NSString *)title message:(NSString *)message
{
    return [[self class] alertControllerWithOKButtonAndTitle:title message:message handler:nil];
}

+ (UIAlertController *)alertControllerWithOKButtonAndTitle:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:handler];
    [alertController addAction:cancelAction];
    return alertController;
}

@end

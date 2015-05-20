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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    return alertController;
}

@end

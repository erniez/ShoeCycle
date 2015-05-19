//
//  UIAlertController+CommonAlerts.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/18/15.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertController (CommonAlerts)

+ (UIAlertController *)alertControllerWithOKButtonAndTitle:(NSString *)title message:(NSString *)message;

@end

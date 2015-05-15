//
//  StravaInteractionViewController.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/7/15.
//
//

#import <UIKit/UIKit.h>

@interface StravaInteractionViewController : UIViewController

@property (nonatomic, copy) void(^completion)(BOOL success, NSError *error);

@end

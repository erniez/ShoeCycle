//
//  StravaInteractionViewController.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/7/15.
//
//

#import <UIKit/UIKit.h>

@interface StravaInteractionViewController : UIViewController

@property (nonatomic, copy) void(^completion)(BOOL success, NSError *error);

@end

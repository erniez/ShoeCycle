//
//  RunShoeMileageAppDelegate.h
//  RunShoeMileage
//
//  Created by Ernie on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShoeCycleAppDelegate : NSObject <UIApplicationDelegate>
{ 
    @public    
    UITabBarController *tabBarController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;

- (void)switchToTab:(int)index;


@end

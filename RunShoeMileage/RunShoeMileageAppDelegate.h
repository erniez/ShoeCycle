//
//  RunShoeMileageAppDelegate.h
//  RunShoeMileage
//
//  Created by Ernie on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunShoeMileageAppDelegate : NSObject <UIApplicationDelegate>
{
@public
    UITabBarController *tabBarController;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;


@end

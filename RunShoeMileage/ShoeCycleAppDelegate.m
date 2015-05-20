//
//  RunShoeMileageAppDelegate.m
//  RunShoeMileage
//
//  Created by Ernie on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShoeCycleAppDelegate.h"
#import "AddDistanceViewController.h"
#import "EditShoesViewController.h"
#import "SetupViewController.h"
#import "EditShoesNavController.h"
#import "ShoeStore.h"
#import <Crashlytics/Crashlytics.h>
#import "UserDistanceSetting.h"
#import "GlobalStringConstants.h"
#import "AFNetworking.h"


@implementation ShoeCycleAppDelegate

@synthesize window, tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the tabBarController
    tabBarController = [[UITabBarController alloc] init];
    
    // Create viewControllers for the tabBar
    AddDistanceViewController *vc1 = [[AddDistanceViewController alloc] initWithNibName:@"AddDistanceViewController" bundle:nil];
    EditShoesViewController *vc2 = [[EditShoesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    SetupViewController *vc3 = [[SetupViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    // Make an array containing the view controllers
    NSArray *viewControllers = [NSArray arrayWithObjects: vc1, navController, vc3, nil];
    
    // Get tab bar item for the Edit shoes navigation controller 
    // If I do the following code in the init of the root view controller, it will not will
    // I would need to create a seperate navigation controller class and override the init field if I don't
    // want the following two lines of code in the App Delegate.
    UITabBarItem *tbi = [navController tabBarItem];
    
    // Give it an image and center
    UIImage *image = [UIImage imageNamed:@"tabbar-shoe.png"];
    [tbi setTitle:@"Add/Edit Shoes"];
    [tbi setImage:image];

    // Attach the array to the tabBarController
    [tabBarController setViewControllers:viewControllers];
    [[self window] setRootViewController:tabBarController];
    
    // Start Crashlytics
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    [Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
    
    [self.window makeKeyAndVisible];
    
    [self monitorVersion];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDoNotShowNewFeaturesKey])
    {
        NSArray *shoes = [[ShoeStore defaultStore] allShoes];
        if ([shoes count] > 0)  // If this is a fresh install, we'll hold off on showing this, until they add a shoe.
        {
            [self displayNewFeaturesInfoOnViewController:vc1];
        }
        
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[ShoeStore defaultStore] saveChangesEZ];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[ShoeStore defaultStore] saveChangesEZ];
    
}

- (void)switchToTab:(int)index
{
    [tabBarController setSelectedIndex:index];
}

- (void)displayNewFeaturesInfoOnViewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Feature!" message:kNewFeaturesInfov2_1String preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *readConfirmation = [UIAlertAction actionWithTitle:@"Don't show again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDoNotShowNewFeaturesKey];
    }];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction: readConfirmation];
    [alert addAction:done];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)monitorVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *storedCurrentVersionString = [defaults stringForKey:kCurrentVersionNumber];
    if (storedCurrentVersionString)
    {
        if ([currentVersionString floatValue] > [storedCurrentVersionString floatValue])
        {
            [defaults setObject:storedCurrentVersionString forKey:kPreviousVersionNumber];
            [defaults setObject:currentVersionString forKey:kCurrentVersionNumber];
            [defaults synchronize];
        }
    }
    else
    {
        [defaults setObject:currentVersionString forKey:kCurrentVersionNumber];
        [defaults synchronize];
    }
}

@end

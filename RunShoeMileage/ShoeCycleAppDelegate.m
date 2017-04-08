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
#import "FTUUtility.h"
#import "ShoeCycle-swift.h"


@implementation ShoeCycleAppDelegate

@synthesize window, tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the tabBarController
    tabBarController = [[UITabBarController alloc] init];
    
    // Create viewControllers for the tabBar
    AddDistanceViewController *vc1 = [[AddDistanceViewController alloc] initWithNibName:@"AddDistanceViewController" bundle:nil];
    EditShoesViewController *vc2 = [[EditShoesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    HOFTableViewController *vc3 = [[HOFTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    SetupViewController *vc4 = [[SetupViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc2];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:vc3];
    
    // Make an array containing the view controllers
    NSArray *viewControllers = [NSArray arrayWithObjects: vc1, navController, navController2, vc4, nil];
    
    // Grab the nav controllers tab bar item (the rootViewController won't work).
    UITabBarItem *tbi = [navController tabBarItem];
    
    // Give it an image and center
    UIImage *image = [UIImage imageNamed:@"tabbar-shoe.png"];
    [tbi setTitle:@"Add/Edit Shoes"];
    [tbi setImage:image];
    
    // Set the tab bar for the Hall of Fame navigation controller.
    UIImage *trophy = [UIImage imageNamed:@"trophy.png"];
    tbi = [navController2 tabBarItem];
    [tbi setTitle:@"Hall of Fame"];
    [tbi setImage:trophy];

    // Attach the array to the tabBarController
    [tabBarController setViewControllers:viewControllers];
    [[self window] setRootViewController:tabBarController];
    
    // Start Crashlytics
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    [Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
    
    [self.window makeKeyAndVisible];
    
    [self monitorVersion];

    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    if ([shoes count] > 0)  // If this is a fresh install, we'll hold off on showing this, until they add a shoe.
    {
        [self displayNewFeaturesInfoOnViewController:vc1];
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
    NSArray *newFeatures = [FTUUtility newFeatures];
    if (newFeatures) {
        NSString *featureText = [FTUUtility featureTextForFeatureKey:[newFeatures firstObject]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Feature!" message:featureText preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *readConfirmation = [UIAlertAction actionWithTitle:@"Don't show again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [FTUUtility completeFeature:[newFeatures firstObject]];
        }];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction: readConfirmation];
        [alert addAction:done];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
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

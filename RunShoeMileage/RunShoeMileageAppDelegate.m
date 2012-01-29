//
//  RunShoeMileageAppDelegate.m
//  RunShoeMileage
//
//  Created by Ernie on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RunShoeMileageAppDelegate.h"
#import "AddDistanceViewController.h"
#import "EditShoesViewController.h"
#import "SetupViewController.h"
#import "EditShoesNavController.h"
#import "ShoeStore.h"

//NSString * const TreadTrackerDistanceUnitPrefKey = @"TreadTrackerDistanceUnitPrefKey";
//NSInteger distanceUnit;
//float const milesToKilometers = 1.609344;

@implementation RunShoeMileageAppDelegate



@synthesize window, tabBarController;
//@synthesize navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the tabBarController
    tabBarController = [[UITabBarController alloc] init];
    
    // Create viewControllers for the tabBar
    AddDistanceViewController *vc1 = [[AddDistanceViewController alloc] init];
    EditShoesViewController *vc2 = [[EditShoesViewController alloc] init];
    SetupViewController *vc3 = [[SetupViewController alloc] init];
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:vc2] autorelease];
    
    // Make an array containing the view controllers
    NSArray *viewControllers = [NSArray arrayWithObjects: vc1, navController, vc3, nil];
    
    // Get tab bar item for the Edit shoes navigation controller 
    // If I do the following code in the init of the root view controller, it will not will
    // I would need to create a seperate navigation controller class and override the init field if I don't
    // want the following two lines of code in the App Delegate.
    UITabBarItem *tbi = [navController tabBarItem];
    
    // Give it a label
    [tbi setTitle:@"Add/Edit Shoes"];

    
    [vc1 release];
    [vc2 release];
    [vc3 release];

    
    // Attach the array to the tabBarController
    [tabBarController setViewControllers:viewControllers];
    
    // Load AddDistanceViewController
//    AddDistanceViewController *addDistanceViewController = [[AddDistanceViewController alloc] init];
//    [[self window] setRootViewController:addDistanceViewController];
    [[self window] setRootViewController:tabBarController];
    [tabBarController release];
    
   // [addDistanceViewController release];
 //   
  //  [window addSubview:navController.view];
    
 //   distanceUnit = [[NSUserDefaults standardUserDefaults] integerForKey:TreadTrackerDistanceUnitPrefKey];
 //   NSLog(@"distanceUnit = %d",distanceUnit);


    [self.window makeKeyAndVisible];
    NSLog(@"View Did Finish Launching");
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
    [[ShoeStore defaultStore] saveChanges];
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
    
    [[ShoeStore defaultStore] saveChanges];
    
}

- (void)dealloc
{
    [window release];
//    [navController release];
    [super dealloc];
}

@end

//
//  EditShoesNavController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditShoesNavController.h"
#import "EditShoesViewController.h"

@implementation EditShoesNavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
                
        // Give it a label
        [tbi setTitle:@"Add/Edit Shoes"];

        }

    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    EditShoesViewController *editShoesViewController = [[EditShoesViewController alloc] init];
    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editShoesViewController];
    
//    [editShoesViewController release];
    
//    [[self window] setRootViewController:editShoesViewController];
    
//    [navController release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

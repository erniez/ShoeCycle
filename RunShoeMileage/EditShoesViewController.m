//
//  EditShoesViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditShoesViewController.h"
#import "ShoeDetailViewController.h"
#import "RunShoeMileageAppDelegate.h"
#import "ShoeStore.h"
#import "Shoe.h"

@implementation EditShoesViewController
@synthesize testBrandArray, testNameArray;


- (id)init
{
    // Call the class designated initializer
 //   self = [super initWithNibName:nil
//                           bundle:nil];
    NSLog(@"Made it to init");
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
/*        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        [tbi setTitle:@"Add/Edit Shoes"];
***  Moved this block of Code to the appDelegate. The title text was not appearing in the tab for some reason */
         NSLog(@"Made it to init Self");
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewShoe:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [bbi release];
        
        [[self navigationItem] setTitle:@"Add/Edit Shoes"];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        
/*        Shoe *ts = [[Shoe alloc] init];  *** Test data no longer needed.
        
        ts = [[ShoeStore defaultStore] createShoe];
        
        ts.brand = @"Test Brand 1";
        ts.desc = @"Test Description 1";
        
        NSLog(@"%@",ts.brand);
        NSLog(@"%@",ts.desc);
        
        ts = [[ShoeStore defaultStore] createShoe];
        
        ts.brand = @"Test Brand 2";
        ts.desc = @"Test Description 2";
        
        NSLog(@"%@",ts.brand);
        NSLog(@"%@",ts.desc);

        ts = [[ShoeStore defaultStore] createShoe];
        
        ts.brand = @"Test Brand 3";
        ts.desc = @"Test Description 3";
        
        NSLog(@"%@",ts.brand);
        NSLog(@"%@",ts.desc);*/
        
//        shoes = [[NSArray alloc] initWithArray:[[ShoeStore defaultStore] allShoes]];
        
//        Shoe *s = [shoes objectAtIndex:0];
        
//        NSLog(@"shoes array %@",s.brand);
//        NSLog(@"shoes array %@",s.desc);
        
        

//        testData = [[ShoesTestData  alloc] init];
 //       NSLog(@"test data count = %d",[testData.testNameArray count]);
    } 
    
    return self;
}


- (id) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
} */


- (void)dealloc
{	
 //   [self.testNameArray release];
//	[self.testBrandArray release];
	
	[super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
//    NSLog(@"Shoe Count = %d", [shoes count]);
}

/*
- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.testBrandArray = [NSArray arrayWithObjects:@"Vibram", @"Brooks", @"Newton", nil];
//    self.testNameArray = [NSArray arrayWithObjects:@"Five Fingers - Bikila", @"Ghost", @"Gravity", nil];  

    
    NSLog(@"Made it to viewDidLoad");

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.testNameArray = nil;
    self.testBrandArray = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
} */


- (void)EditShoesViewControllerWillDismiss:(EditShoesViewController *)vc
{
    [[self tableView] reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ******************************************************************************************
//  End of View Cycle
// ==========================================================================================


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [testData.testNameArray count];
    NSLog(@"Tableview Shoe Count = %d",[[[ShoeStore defaultStore] allShoes] count]);
    return [[[ShoeStore defaultStore] allShoes] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
// pwc   ShoesTestData *testData = [[ShoesTestData alloc] init];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"] autorelease];
	}
    
// pwc    cell.textLabel.text = [testData.testBrandArray objectAtIndex:indexPath.row];
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    Shoe *s = [shoes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = s.brand;
    cell.detailTextLabel.text = s.desc;

// pwc    cell.detailTextLabel.text = [testData.testNameArray objectAtIndex:indexPath.row];      
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSLog(@"Made it to tableView exit");
    
	return cell;

} 


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoeDetailViewController *detailViewController = [[[ShoeDetailViewController alloc] init] autorelease];
    
//    detailViewController.testBrandString = [testData.testBrandArray objectAtIndex:indexPath.row];
//    detailViewController.testNameString = [testData.testNameArray objectAtIndex:indexPath.row];
    
//    Shoe *s = [shoes objectAtIndex:indexPath.row];
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
//    detailViewController.testBrandString = s.brand;
//    detailViewController.testNameString = s.desc;

    [detailViewController setShoe:[shoes objectAtIndex:indexPath.row]];
    
//    NSLog(@"didSelectRow Brand = %@",s.brand);

    
    [[self navigationController] pushViewController:detailViewController animated:YES];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ShoeStore *ss = [ShoeStore defaultStore];
        NSArray *shoes = [ss allShoes];
        Shoe *s = [shoes objectAtIndex:[indexPath row]];
        [ss removeShoe:s];
        
        // remove row from table with animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ShoeStore defaultStore] moveShoeAtIndex:[fromIndexPath row] toIndex:[toIndexPath row]];
}


- (IBAction)addNewShoe:(id)sender
{
    Shoe *newShoe = [[ShoeStore defaultStore] createShoe];
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] initForNewItem:YES];
    
//    NSArray *otherShoes = [[NSArray alloc] initWithArray:[[ShoeStore defaultStore] allShoes]];
    
    newShoe.brand = @"test123";
    
//    NSLog(@"Other Shoes Count = %d",[otherShoes count]);
//    NSLog(@"All Shoe Count = %d",[shoes count]);
    
    [detailViewController setShoe:newShoe];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:NULL];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:NULL];
    
    NSArray *items = [NSArray arrayWithObjects:camera, spacer, trash, nil];
    
    [toolBar setItems:items animated:YES];
    
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [toolBar release];
    [camera release];
    [spacer release];
    [trash release];
    
    [self presentModalViewController:navController animated:YES];
    
//    [self.tabBarController presentModalViewController:navController animated:YES];
//    *** can't figure out how to present a modal view without covering tabBarController


    [detailViewController release];
    [navController release];
}
@end

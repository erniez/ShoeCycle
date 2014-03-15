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
#import "UserDistanceSetting.h"

@implementation EditShoesViewController
//@synthesize testBrandArray, testNameArray;


- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
/*        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        [tbi setTitle:@"Add/Edit Shoes"];
***  Moved this block of Code to the appDelegate. The title text was not appearing in the tab for some reason */
        EZLog(@"Made it to init Self");
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewShoe:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
                
        [[self navigationItem] setTitle:@"Add/Edit Shoes"];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
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


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    EZLog(@"entered editShoes didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    EZLog(@"leaving editShoed didReceiveMemoryWarning");    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentShoe = [UserDistanceSetting getSelectedShoe];
    [[self tableView] reloadData];
    self.tableView.backgroundColor = [UIColor clearColor]; 
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.tableView.contentMode = UIViewContentModeTop;
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"plain-wallpaper.png"]];

    EZLog(@"******* View Will Appear currentShoe = %i", currentShoe);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    
    EZLog(@"Made it to viewDidLoad");

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
} 


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
    int cnt = [[[ShoeStore defaultStore] allShoes] count];
    EZLog(@"Tableview Shoe Count = %d",[[[ShoeStore defaultStore] allShoes] count]);
    // Check to see if current shoe was deleted, then set current shoe to top shoe.
    if (currentShoe >= cnt) {
        currentShoe = 0;
        [UserDistanceSetting setSelectedShoe:currentShoe];
    }
    return cnt; //[[[ShoeStore defaultStore] allShoes] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
	}
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    EZLog(@"index path = %i",indexPath.row);
    
    Shoe *s = [shoes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",s.brand];
    cell.detailTextLabel.text = nil;
    if (indexPath.row == currentShoe) {
        cell.detailTextLabel.text = @"Selected";
    }   
	
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton ;
    
    EZLog(@"Made it to tableView exit");
    
	return cell;
} 


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] init];
       
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
        
    [detailViewController setShoe:[shoes objectAtIndex:indexPath.row]];

    [[self navigationController] pushViewController:detailViewController animated:YES];
    
    EZLog(@"********** Going to Detail View ***************");
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZLog(@"Entering did select row at index path");
    currentShoe = indexPath.row;
    [UserDistanceSetting setSelectedShoe:currentShoe];
    [[self tableView] reloadData];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ShoeStore *ss = [ShoeStore defaultStore];
        NSArray *shoes = [ss allShoes];
        Shoe *s = [shoes objectAtIndex:[indexPath row]];
        [ss removeShoe:s];
        
/*        if (currentShoe == [indexPath row]) {
            currentShoe = 0;
            [UserDistanceSetting setSelectedShoe:currentShoe];
        }*/
        
        // remove row from table with animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [[self tableView] reloadData];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ShoeStore defaultStore] moveShoeAtIndex:[fromIndexPath row] toIndex:[toIndexPath row]];
}


- (IBAction)addNewShoe:(id)sender
{
    NSTimeInterval secondsInSixMonths = 6 * 30.4 * 24 * 60 * 60;
    
    Shoe *newShoe = [[ShoeStore defaultStore] createShoe];
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] initForNewItem:YES];
    
//    NSArray *otherShoes = [[NSArray alloc] initWithArray:[[ShoeStore defaultStore] allShoes]];
    
//    newShoe.brand = @"test123";
    newShoe.maxDistance = [NSNumber numberWithFloat:350];
    newShoe.startDate = [NSDate date];
    newShoe.expirationDate = [newShoe.startDate dateByAddingTimeInterval:secondsInSixMonths];    
    
    [detailViewController setShoe:newShoe];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:NULL];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:NULL];
    
    NSArray *items = [NSArray arrayWithObjects:camera, spacer, trash, nil];
    
    [toolBar setItems:items animated:YES];
    
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navController animated:YES completion:nil];
    
//    [self.tabBarController presentModalViewController:navController animated:YES];
//    *** can't figure out how to present a modal view without covering tabBarController

}
@end

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
***  Moved this block of Code to the appDelegate        */
         NSLog(@"Made it to init Self");
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewShoe:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [bbi release];
        
        [[self navigationItem] setTitle:@"Add/Edit Shoes"];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        
        testData = [[ShoesTestData  alloc] init];
        NSLog(@"test data count = %d",[testData.testNameArray count]);
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
    [self.testNameArray release];
	[self.testBrandArray release];
	
	[super dealloc];
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
	// return [testBrandArray count];
//    NSLog(@"test data count = %d",[testData.testNameArray count]);
    return [testData.testNameArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"Made it to tableView");
    
    static NSString *kCustomCellID = @"CustomCellID";
    
    NSLog(@"Made it to tableView");
 //   NSLog(@"%d",[self.testBrandArray count]);
	
//    ShoesTestData *testData = [[ShoesTestData alloc] init];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCustomCellID] autorelease];
	}
    
	NSLog(@"Made it to tableView");
    NSLog(@"testData count in tableview = %d",[testData.testNameArray count]);

//	NSString *cellValue = [self.testBrandArray objectAtIndex:indexPath.row];
    
//    cell.textLabel.text = [self.testBrandArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [testData.testBrandArray objectAtIndex:indexPath.row];

    
//	cell.detailTextLabel.text = [testNameArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [testData.testNameArray objectAtIndex:indexPath.row];

//    cell.textLabel.text = @"%f",indexPath.row;
//    NSLog(@"Row %d",indexPath.row);
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSLog(@"Made it to tableView exit");
    
	return cell;

} 


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoeDetailViewController *detailViewController = [[[ShoeDetailViewController alloc] init] autorelease];
    
    detailViewController.testBrandString = [testData.testBrandArray objectAtIndex:indexPath.row];
    detailViewController.testNameString = [testData.testNameArray objectAtIndex:indexPath.row];
    
 //   detailViewController.testBrandString = @"test"; 
    
//    [detailViewController.brandField setText:(@"???")];
    
    NSLog(@"%@",[testData.testBrandArray objectAtIndex:indexPath.row]);

    
    [[self navigationController] pushViewController:detailViewController animated:YES];
}


- (IBAction)addNewShoe:(id)sender
{
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] initForNewItem:YES];
    
//    RunShoeMileageAppDelegate *appDelegate = (RunShoeMileageAppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    UITabBarController *myProperty = appDelegate.tabBarController;

    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    

    
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentModalViewController:navController animated:YES];
    
//    [self.tabBarController presentModalViewController:navController animated:YES];
//    *** can't figure out how to present a modal view without covering tabBarController


    [detailViewController release];
    [navController release];
}
@end

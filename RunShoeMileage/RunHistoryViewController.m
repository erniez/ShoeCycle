//
//  RunHistoryViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RunHistoryViewController.h"
#import "History.h"
#import "UserDistanceSetting.h"
#import "ShoeStore.h"



@implementation RunHistoryViewController

@synthesize shoe, runs;
@synthesize tableHeaderView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                       target:self
                                       action:@selector(cancel:)];

        [[self navigationItem] setLeftBarButtonItem:cancelItem];
        
        [[self navigationItem] setTitle:@"Run History"];
        
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
  
    // Create and set the table header view.

    UIView *containerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
    UILabel *headerLabel = 
        [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 80, 21)];

    headerLabel.text = NSLocalizedString(@"Run Date", @"");
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.backgroundColor = [UIColor clearColor];
    
    [containerView addSubview:headerLabel];
    
    UILabel *headerLabel2;
    if ([UserDistanceSetting getDistanceUnit]) {
        headerLabel2 =
            [[UILabel alloc] initWithFrame:CGRectMake(207, 5, 107, 21)];

        headerLabel2.text = NSLocalizedString(@"Distance(km)", @"");
        
    }
    else {
        headerLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(186, 5, 130, 21)];
        
        headerLabel2.text = NSLocalizedString(@"Distance(miles)", @"");
   
    }
    headerLabel2.textColor = [UIColor blackColor];
    headerLabel2.font = [UIFont boldSystemFontOfSize:17];
    headerLabel2.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel2];

    self.tableView.tableHeaderView = containerView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewDidUnload
{
    tableHeaderView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:[shoe.history allObjects]];
	[sortedRuns sortUsingDescriptors:sortDescriptors];
	self.runs = sortedRuns;

    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
} */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [shoe.history count];
    return [runs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSDateFormatter *dateFormatter;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    History *hist = [runs objectAtIndex:indexPath.row];
    
    dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    cell.textLabel.text = [dateFormatter stringFromDate:hist.runDate];
    cell.detailTextLabel.text = [UserDistanceSetting displayDistance:[hist.runDistance floatValue]];
    EZLog (@"hist.runDate = %@", hist.runDate);
    EZLog (@"hist.runDistance = %@",hist.runDistance);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
                                            forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EZLog(@"shoe.history mathched item: %@ ********", [shoe.history member:[runs objectAtIndex:[indexPath row]]]);
        
        [[ShoeStore defaultStore] removeHistory:[shoe.history member:[runs objectAtIndex:[indexPath row]]] atShoe:shoe];
        
        EZLog(@"runs = %@",runs);
        [runs removeObjectAtIndex:[indexPath row]];
        EZLog(@"index path = %ld",(long)[indexPath row]);
        EZLog(@"runs = %@",runs);
        EZLog(@"history count after delete = %lu",(unsigned long)[shoe.history count]);
        // remove row from table with animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [[self tableView] reloadData];
        [[ShoeStore defaultStore] saveChangesEZ];       // Save context
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}*/



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     
}*/

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  RunHistoryViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RunHistoryViewController.h"
#import "History.h"



@implementation RunHistoryViewController

@synthesize shoe, runs;
@synthesize tableHeaderView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
        [cancelItem release];
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
/*    if (tableHeaderView == nil) {
//        [[NSBundle mainBundle] loadNibNamed:@"RunHistoryTableHeaderView" owner:self options:nil];
        self.tableView.tableHeaderView = tableHeaderView;
        NSLog(@"Made inside if statement of tableview header");
//        self.tableView.allowsSelectionDuringEditing = YES;
    } */
    UIView *containerView =
    [[[UIView alloc]
      initWithFrame:CGRectMake(0, 0, 300, 35)]
     autorelease];
    UILabel *headerLabel =
    [[[UILabel alloc]
      initWithFrame:CGRectMake(11, 5, 80, 21)]
     autorelease];
    headerLabel.text = NSLocalizedString(@"Run Date", @"");
    headerLabel.textColor = [UIColor blackColor];
//    headerLabel.shadowColor = [UIColor blackColor];
//    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    
    UILabel *headerLabel2 =
    [[[UILabel alloc]
      initWithFrame:CGRectMake(240, 5, 75, 21)]
     autorelease];
    headerLabel2.text = NSLocalizedString(@"Distance", @"");
    headerLabel2.textColor = [UIColor blackColor];
    //    headerLabel.shadowColor = [UIColor blackColor];
    //    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel2.font = [UIFont boldSystemFontOfSize:17];
    headerLabel2.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel2];

    self.tableView.tableHeaderView = containerView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [tableHeaderView release];
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
    
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedRuns release];

    
    
//    self.runs = [[NSMutableArray alloc] initWithArray:[shoe.history allObjects]];
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
    return [shoe.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSDateFormatter *dateFormatter;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    History *hist = [runs objectAtIndex:indexPath.row];
    
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    cell.textLabel.text = [dateFormatter stringFromDate:hist.runDate];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",[hist.runDistance floatValue]];
    NSLog (@"hist.runDistance = %@",hist.runDistance);
    
    [numberFormatter release];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    [self dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
    [tableHeaderView release];
    [super dealloc];
}
@end

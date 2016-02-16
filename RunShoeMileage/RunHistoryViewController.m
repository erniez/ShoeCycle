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
#import "DateUtilities.h"


@interface RunHistoryViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *runsByTheMonth;
@property (weak, nonatomic) IBOutlet UILabel *runDateHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceHeaderLabel;
@property (nonatomic) IBOutlet UIView *noRunHistoryView;

@end


@implementation RunHistoryViewController

@synthesize shoe, runs;
@synthesize tableHeaderView;

- (id)init
{
    self = [super init];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Configure the sticky table header view.
    self.runDateHeaderLabel.text = NSLocalizedString(@"Run Date", @"");
    self.runDateHeaderLabel.textColor = [UIColor blackColor];
    self.runDateHeaderLabel.font = [UIFont boldSystemFontOfSize:17];
    self.runDateHeaderLabel.backgroundColor = [UIColor clearColor];

    if ([UserDistanceSetting getDistanceUnit]) {
        self.distanceHeaderLabel.text = NSLocalizedString(@"Distance(km)", @"");
    }
    else {
        self.distanceHeaderLabel.text = NSLocalizedString(@"Distance(miles)", @"");
    }
    
    self.distanceHeaderLabel.textColor = [UIColor blackColor];
    self.distanceHeaderLabel.font = [UIFont boldSystemFontOfSize:17];
    self.distanceHeaderLabel.backgroundColor = [UIColor clearColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:[shoe.history allObjects]];
	[sortedRuns sortUsingDescriptors:sortDescriptors];
	self.runs = sortedRuns;

    self.runsByTheMonth = [NSMutableArray new];
    NSMutableArray *runsForTheMonth = [NSMutableArray new];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger previousMonth = 0;
    NSInteger previousYear = 0;
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    
    for (History *history in self.runs) {
        NSDateComponents *components = [calendar components:unitFlags fromDate:history.runDate];
        NSInteger year = [components year];
        NSInteger month = [components month];
        if (month != previousMonth || year != previousYear) {
            if ([runsForTheMonth count] > 0) {
                [self.runsByTheMonth addObject:[runsForTheMonth mutableCopy]];
            }
            [runsForTheMonth removeAllObjects];
        }
        [runsForTheMonth addObject:history];
        previousYear = year;
        previousMonth = month;
    }
    if ([runsForTheMonth count] > 0) {
        [self.runsByTheMonth addObject:[runsForTheMonth mutableCopy]];
        [self.tableView reloadData];
    }
    else {
        [self configureForNoRunHistory];
    }
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)configureForNoRunHistory
{
    self.noRunHistoryView.frame = self.tableView.frame;
    self.noRunHistoryView.alpha = 1.0;
    self.tableView.alpha = 0;
    self.runDateHeaderLabel.alpha = 0;
    self.distanceHeaderLabel.alpha = 0;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view addSubview:self.noRunHistoryView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.runsByTheMonth count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.runsByTheMonth[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSDateFormatter *dateFormatter;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    History *hist = self.runsByTheMonth[indexPath.section][indexPath.row];
    
    dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    cell.textLabel.text = [dateFormatter stringFromDate:hist.runDate];
    cell.detailTextLabel.text = [UserDistanceSetting displayDistance:[hist.runDistance floatValue]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
                                            forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EZLog(@"shoe.history mathched item: %@ ********", [shoe.history member:[runs objectAtIndex:[indexPath row]]]);
        NSMutableArray *runsForTheMonth = self.runsByTheMonth[indexPath.section];
        History *shoeHistoryEntry = runsForTheMonth[indexPath.row];
        [[ShoeStore defaultStore] removeHistory:[shoe.history member:shoeHistoryEntry] atShoe:shoe];
        [runsForTheMonth removeObjectAtIndex:indexPath.row];
        EZLog(@"runs = %@",runs);
        [runs removeObjectAtIndex:[indexPath row]];
        EZLog(@"index path = %ld",(long)[indexPath row]);
        EZLog(@"runs = %@",runs);
        EZLog(@"history count after delete = %lu",(unsigned long)[shoe.history count]);
        // remove row from table with animation
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if ([self.runsByTheMonth count] == 0) {
                // If we don't have anymore run history, then show the no run history view.
                self.noRunHistoryView.frame = self.tableView.frame;
                self.noRunHistoryView.alpha = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    [self configureForNoRunHistory];
                }];
            }
            else {
                [[self tableView] reloadData];
            }
        }];
        [tableView beginUpdates];
        if ([runsForTheMonth count] == 0) {
            [self.runsByTheMonth removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [tableView endUpdates];
        [CATransaction commit];

        [[ShoeStore defaultStore] saveChangesEZ];       // Save context
    }
}


#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    UILabel *monthLabel = [UILabel new];
    History *history = self.runsByTheMonth[section][0];
    monthLabel.text = [DateUtilities monthStringFromDate:history.runDate];
    [monthLabel sizeToFit];
    CGRect labelFrame = monthLabel.frame;
    labelFrame.origin.x = 8.0;
    labelFrame.origin.y = headerView.bounds.size.height/2 - monthLabel.bounds.size.height/2;
    monthLabel.frame = labelFrame;
    [headerView addSubview:monthLabel];
    UILabel *totalLabel = [UILabel new];
    NSArray *monthOfRuns = self.runsByTheMonth[section];
    CGFloat totalDistance = 0.0;
    for (History *runHistory in monthOfRuns) {
        totalDistance += [runHistory.runDistance floatValue];
    }
    totalLabel.text = [UserDistanceSetting displayDistance:totalDistance];
    [totalLabel sizeToFit];
    CGRect runTotalFrame = CGRectMake(self.view.bounds.size.width - totalLabel.bounds.size.width - 8.0,
                                      headerView.bounds.size.height/2 - monthLabel.bounds.size.height/2,
                                      totalLabel.bounds.size.width,
                                      totalLabel.bounds.size.height);
    totalLabel.frame = runTotalFrame;
    [headerView addSubview:totalLabel];
    return headerView;
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

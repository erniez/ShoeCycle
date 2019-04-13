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
#import "Shoe+Helpers.h"
#import "ShoeCycle-Swift.h"

#import <MessageUI/MessageUI.h>


@interface RunHistoryViewController ()  <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *runsByTheMonth;
@property (weak, nonatomic) IBOutlet UILabel *runDateHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceHeaderLabel;
@property (nonatomic) IBOutlet UIView *noRunHistoryView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailDataButton;

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
    self.runDateHeaderLabel.text = @"Run Date";
    self.runDateHeaderLabel.textColor = [UIColor blackColor];
    self.runDateHeaderLabel.font = [UIFont boldSystemFontOfSize:17];
    self.runDateHeaderLabel.backgroundColor = [UIColor clearColor];

    if ([UserDistanceSetting getDistanceUnit]) {
        self.distanceHeaderLabel.text = @"Distance(km)";
    }
    else {
        self.distanceHeaderLabel.text = @"Distance(miles)";
    }
    
    self.distanceHeaderLabel.textColor = [UIColor blackColor];
    self.distanceHeaderLabel.font = [UIFont boldSystemFontOfSize:17];
    self.distanceHeaderLabel.backgroundColor = [UIColor clearColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.runs = [[self.shoe sortedRunHistoryAscending:NO] mutableCopy];

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
    self.emailDataButton.enabled = NO;
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
        [[ShoeStore defaultStore] saveChangesEZ];
        [[ShoeStore defaultStore] updateTotalDistanceForShoe:shoe];
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
        [self.delegate runHistoryDidChangeWithShoe:self.shoe];
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

- (IBAction)emailButtonTapped:(UIBarButtonItem *)sender
{
    EmailUtility *mailUtility = [EmailUtility new];
    UIViewController *mailViewController = [mailUtility newMailComposerViewController];
    if ([mailViewController isKindOfClass:[UIAlertController class]]) {
        //HAX: The following line fixes some weird collection view error that was being displayed in the debug console.
        // Something to do with the flow layout not being set up properly. It did not crash, it just wrote some garbage
        // text to the console.  So, we're forcing a layout pass before presenting which appears to allieviate the issue.
        // Since this code will hardly ever execute, I did not research it too deeply.
        [mailViewController.view layoutIfNeeded];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        if ([MFMailComposeViewController canSendMail]) {
            CSVUtility *csvUtility = [[CSVUtility alloc] init];
            NSString *csvString = [csvUtility createCSVDataFromShoe:self.shoe];
            MFMailComposeViewController *mailer = (MFMailComposeViewController *)mailViewController;
            
            mailer.mailComposeDelegate = self;
            
            [mailer setSubject: [NSString stringWithFormat:@"CSV data from ShoeCycle shoe: %@",
                                 self.shoe.brand]];
            
            [mailer addAttachmentData:[csvString dataUsingEncoding:NSUTF8StringEncoding]
                             mimeType:@"text/csv"
                             fileName:[NSString stringWithFormat:@"ShoeCycleShoeData-%@.csv",self.shoe.brand]];
            
            NSString *emailBody = @"Attached is the CSV shoe data from ShoeCycle!";
            
            [mailer setMessageBody:emailBody isHTML:NO];
            
            [self presentViewController:mailer animated:YES completion:nil];
        }
        else {
            [self showNoMailAvailableAlert];
        }
        
    }
}

- (void)showNoMailAvailableAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"You do not have the ability to send email on this device" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (!error) {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"Mail saved: you saved the email message in the drafts folder.");
                break;
            case MFMailComposeResultSent:
                NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
                break;
            default:
                NSLog(@"Mail not sent.");
                break;
        }
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

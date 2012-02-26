//
//  AddDistanceViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddDistanceViewController.h"
#import "StandardDistancesViewController.h"
#import "RunHistoryViewController.h"
#import "ShoeStore.h"
#import "Shoe.h"
#import "History.h"
#import "UserDistanceSetting.h"
#import "RunShoeMileageAppDelegate.h"

extern NSInteger distanceUnit;
float const milesToKilometers;
float runTotal;

@implementation AddDistanceViewController
@synthesize startDateLabel;
@synthesize expirationDateLabel;
@synthesize daysLeftLabel;
@synthesize daysLeftIdentificationLabel;
@synthesize wearProgress;
@synthesize nameField;
@synthesize runDateField;
@synthesize maxDistanceLabel;
@synthesize enterDistanceField;
@synthesize totalDistanceLabel, distanceUnitLabel;
@synthesize pickerView, doneButton,runDateFormatter; // standardDistanceString;
@synthesize distShoe, addRunDate, hist;
@synthesize totalDistanceProgress;


- (id)init
{
    // Call the class designated initializer
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        // Get tab bar item
        int offset = 7;
        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        UIImage *image = [UIImage imageNamed:@"tabbar-add.png"];
 //       [tbi setTitle:@"Add Distance"];
        tbi.imageInsets = imageInset;
        [tbi setImage:image];
        
        standardDistance = 0;
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void) viewWillAppear:(BOOL)animated
{
    
//    NSLog(@"standardDistanceString = %@", standardDistanceString);
    if (standardDistance != 0) {
        [enterDistanceField setText:[UserDistanceSetting displayDistance:standardDistance]];
    }

    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    NSLog(@"History count = %d",[distShoe.history count]);
    
    if ([shoes count] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You first need to add a shoe before you can add a distance."
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert autorelease];
    [alert show];
    return;
    }
    
    if (([shoes count]-1) >= [UserDistanceSetting getSelectedShoe]){
        distShoe = [shoes objectAtIndex:[UserDistanceSetting getSelectedShoe]];
    }
    else {
        distShoe = [shoes objectAtIndex:0];
    }
    
    runTotal = [distShoe.startDistance floatValue];
    if ([distShoe.history count]) {
        NSMutableArray *runs = [[NSMutableArray alloc] initWithArray:[distShoe.history allObjects]];
        int i = 0;
        do {
            History *tempHist = [runs objectAtIndex:i];
            runTotal = runTotal +  [tempHist.runDistance floatValue];
            NSLog (@"runDistance = %f",[tempHist.runDistance floatValue]);
            i++;
        } while (i < [distShoe.history count]);
        NSLog(@"run total = %f",runTotal);
        [runs release];
    }
    
    nameField.text = [NSString stringWithFormat:@"%@",distShoe.brand];
    distanceUnitLabel.text = @"Miles";
    if ([UserDistanceSetting getDistanceUnit]) {
        distanceUnitLabel.text = @"Km";
    }
    totalDistanceProgress.progress = runTotal/distShoe.maxDistance.floatValue;
    [maxDistanceLabel setText:[NSString stringWithFormat:@"%@",[UserDistanceSetting displayDistance:[distShoe.maxDistance floatValue]]]];
    NSLog(@"run total2 = %f",runTotal);
    self.runDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.runDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.runDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    runDateField.delegate = self;
    //    NSLog(@"%@",[self.runDateFormatter stringFromDate:[NSDate date]]);
    self.addRunDate = [NSDate date];
    NSLog(@"run date = %@",addRunDate);
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
    NSLog(@"run total3 = %f",runTotal);
    
    [self calculateDaysLeftProgressBar];
    
    [imageView setImage:[distShoe thumbnail]];

    NSLog(@"Leaving View Will Appear");
//    [totalDistanceField setText:[UserDistanceSetting displayDistance:[distShoe.totalDistance floatValue]]];
    NSLog(@"run total last = %f",runTotal);
    [totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];

}

- (void) viewDidAppear:(BOOL)animated
{
/*    if (standardDistanceString != nil) {
        [enterDistanceField setText:standardDistanceString];
    } */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    enterDistanceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        enterDistanceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    if ([shoes count]) {
        if (([shoes count]-1) >= [UserDistanceSetting getSelectedShoe]){
            distShoe = [shoes objectAtIndex:[UserDistanceSetting getSelectedShoe]];
        }
        else {
            distShoe = [shoes objectAtIndex:0];
        }
    }
    
    nameField.text = distShoe.brand;
/*    float displayValue = [distShoe.totalDistance floatValue];
    if ([UserDistanceSetting getDistanceUnit]) {
        displayValue = displayValue * milesToKilometers;
    } */
    
    [totalDistanceLabel setText:[UserDistanceSetting displayDistance:[distShoe.totalDistance floatValue]]];
    

    // Need the following code to register to update date calculation if app has been in background for more than a day
    // otherwise, days left does not update, because viewWillAppear will not be called upon return from background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calculateDaysLeftProgressBar) name:UIApplicationWillEnterForegroundNotification object:nil];

      
    NSLog(@"View Did Load addDistanceViewController");
    
//    [totalDistanceField setText:[NSString stringWithFormat:@"%.1f",shoe.totalDistance]];

//    [self setTotalDistanceField:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    standardDistance = 0;
    [enterDistanceField setText:nil];
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self callDP:nil];
    return NO;
    
}



- (void)viewDidUnload
{
    [enterDistanceField release];
    [self setEnterDistanceField:nil];
    [self setTotalDistanceLabel:nil];
    [runDateField release];
    [runDateField release];
    [self setRunDateField:nil];
    [self setNameField:nil];
    [self setTotalDistanceProgress:nil];
    [self setMaxDistanceLabel:nil];
    [imageView release];
    imageView = nil;
    [self setStartDateLabel:nil];
    [self setExpirationDateLabel:nil];
    [self setDaysLeftLabel:nil];
    [self setWearProgress:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [enterDistanceField release];
    [totalDistanceLabel release];
    [runDateField release];
    [runDateField release];
    [runDateField release];
    [distShoe release];
    [nameField release];
    [totalDistanceProgress release];
    [maxDistanceLabel release];
    [imageView release];
    [addRunDate release];
    [startDateLabel release];
    [expirationDateLabel release];
    [daysLeftLabel release];
    [wearProgress release];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // must delloc from notification center or program will crash
    [super dealloc];
}


- (IBAction)backgroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)addDistanceButton:(id)sender 
{
    float addDistance;
    NSManagedObjectContext *context = [distShoe managedObjectContext];
    NSDate *testDate; // temporary date that gets written to run history table
    
    // clear any editors that may be visible (clicking directly from distance number pad)
    [[self view] endEditing:YES];
    

    addDistance = [UserDistanceSetting enterDistance:[enterDistanceField text]]; 
    if (standardDistance) {
        addDistance = standardDistance;
    }
    if (!addDistance) {
        return;
    }
    NSLog(@"addDistance = %.2f",addDistance);
    testDate = self.addRunDate;
    
    [[ShoeStore defaultStore] setRunDistance:addDistance];
    
//    NSArray *allDistances = [[ShoeStore defaultStore] allRunDistances];
//    NSManagedObject *runDist = [allDistances objectAtIndex:0];
    self.hist = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
    [distShoe addHistoryObject:hist];
    hist.runDistance = [NSNumber numberWithFloat:addDistance];
    NSLog(@"setting history run distance = %@",hist.runDistance);
    hist.runDate = testDate;
   
    NSMutableArray *runDistances = [[NSMutableArray alloc] initWithArray:[distShoe.history allObjects]];
    NSManagedObject *runDist = [runDistances objectAtIndex:0];
    NSString *displayDistance = [runDist valueForKey:@"runDistance"];
    
    NSLog(@"%@",hist.runDistance);
    NSLog(@"Top of runDistance: %@",displayDistance);
    
    runTotal = runTotal + addDistance;
    [totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];
    
    enterDistanceField.text = nil;
    standardDistance = 0;
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
    totalDistanceProgress.progress = runTotal/distShoe.maxDistance.floatValue;
    
    [runDistances release];
    
}


- (IBAction)callDP:(id)sender {
    
    [[self view] endEditing:YES];           // clear any editors that may be visible (clicking from distance to date)
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    pickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    pickerView.tag = 10;
    pickerView.datePickerMode = UIDatePickerModeDate;
//    [pickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancel:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [closeButton release];
    
    
    //[actionSheet showInView:self.view];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)standardDistancesButtonPressed:(id)sender
{
    [[self view] endEditing:YES];           // clear any editors that may be visible
    
    StandardDistancesViewController *modalViewController = [[StandardDistancesViewController alloc] initWithDistance:self];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];

    
    
    [self presentModalViewController:navController animated:YES];
 
    [modalViewController release];
    [navController release];    
}

- (IBAction)runHistoryButtonPressed:(id)sender 
{
    [[self view] endEditing:YES];           // clear any editors that may be visible
    
    RunHistoryViewController *modalViewController = [[RunHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    modalViewController.shoe = distShoe;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
   
    [self presentModalViewController:navController animated:YES];
    
    [modalViewController release];
    [navController release];    
}


- (void)actionSheetCancel:(id)sender
{
    NSLog(@"actionSHeetCancel");
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"%@",[self.runDateFormatter stringFromDate:self.pickerView.date]);
//    [runDateField setText:[NSString stringWithFormat:[self.runDateFormatter stringFromDate:self.pickerView.date]]];
    self.addRunDate = self.pickerView.date;
    [runDateField setText:[self.runDateFormatter stringFromDate:self.pickerView.date]];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    RunShoeMileageAppDelegate *appDelegate = (RunShoeMileageAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToTab:1];
}


- (void)calculateDaysLeftProgressBar
{
    BOOL dateError = FALSE;
    NSComparisonResult result = [distShoe.expirationDate compare:distShoe.startDate];
    
    if (result == NSOrderedAscending) {
        dateError = TRUE;
    }
    [startDateLabel setText:[NSString stringWithFormat:@"%@",[self.runDateFormatter stringFromDate:distShoe.startDate]]];
    [expirationDateLabel setText:[NSString stringWithFormat:@"%@",[self.runDateFormatter stringFromDate:distShoe.expirationDate]]];
    if (dateError) {
        [expirationDateLabel setText:@" "];
        [startDateLabel setText:@"Your end date is earlier than your start date"];
    }
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:[NSDate date]
                                                          toDate:distShoe.expirationDate
                                                         options:0];
    
    NSDateComponents *componentsTotal = [gregorianCalendar components:NSDayCalendarUnit
                                                             fromDate:distShoe.startDate
                                                               toDate:distShoe.expirationDate
                                                              options:0];
    
    
    [gregorianCalendar release];
    [daysLeftIdentificationLabel setText:@"Days Left"];
    [daysLeftLabel setText:@"0"];
    if (([components day]+1) >= 0) {
        [daysLeftLabel setText:[NSString stringWithFormat:@"%d",([components day]+1)]];
    }
    if (([components day]+1) == 1) {
        [daysLeftIdentificationLabel setText:@"Day Left"];
    }
    
    NSLog(@"Components Total = %d",([components day]+1));
    int daysTotal = [componentsTotal day];
    int daysLeftToWear = ([components day]+1);
    float wear = 0;
    wear = (float)daysLeftToWear/(float)daysTotal;
    wearProgress.progress = 1 - wear;
    //    NSLog(@"Wear Progress = %@",wearProgress.progress);
    NSLog(@"Wear Days = %d and %d",daysLeftToWear, daysTotal);
    
    NSLog(@"Wear = %.4f",wear);

}

@end

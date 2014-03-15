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
@synthesize pickerView, runDateFormatter; // standardDistanceString;
@synthesize distShoe, addRunDate, hist;
@synthesize totalDistanceProgress;


- (id)init
{
    // Call the class designated initializer
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        // Get tab bar item
//        int offset = 7;
//        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        UIImage *image = [UIImage imageNamed:@"tabbar-add.png"];
        [tbi setTitle:@"Add Distance"];
//        tbi.imageInsets = imageInset;
        [tbi setImage:image];
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
    EZLog(@"entered addDistance didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    EZLog(@"leaving addDistance didReceiveMemoryWarning");    
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    EZLog(@"History count = %d",[distShoe.history count]);
    
    if ([shoes count] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You first need to add a shoe before you can add a distance."
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
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
        NSInteger i = 0;
        do {
            History *tempHist = [runs objectAtIndex:i];
            runTotal = runTotal +  [tempHist.runDistance floatValue];
            EZLog (@"runDistance = %f",[tempHist.runDistance floatValue]);
            i++;
        } while (i < [distShoe.history count]);
        EZLog(@"run total = %f",runTotal);
    }
    
    nameField.text = [NSString stringWithFormat:@"%@",distShoe.brand];
    distanceUnitLabel.text = @"Miles";
    if ([UserDistanceSetting getDistanceUnit]) {
        distanceUnitLabel.text = @"Km";
    }
    totalDistanceProgress.progress = runTotal/distShoe.maxDistance.floatValue;
    [maxDistanceLabel setText:[NSString stringWithFormat:@"%@",[UserDistanceSetting displayDistance:[distShoe.maxDistance floatValue]]]];
    EZLog(@"run total2 = %f",runTotal);

    EZLog(@"run total3 = %f",runTotal);
    
    [self calculateDaysLeftProgressBar];
    
    [self.imageView setImage:[distShoe thumbnail]];

    EZLog(@"Leaving View Will Appear");
    EZLog(@"run total last = %f",runTotal);
    [totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];

}

- (void) viewDidAppear:(BOOL)animated
{

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
    
    self.runDateFormatter = [[NSDateFormatter alloc] init];
	[self.runDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.runDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    runDateField.delegate = self;
    EZLog(@"%@",[self.runDateFormatter stringFromDate:[NSDate date]]);
    self.addRunDate = [NSDate date];
    EZLog(@"run date = %@",addRunDate);
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];

    // Need the following code to register to update date calculation if app has been in background for more than a day
    // otherwise, days left does not update, because viewWillAppear will not be called upon return from background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calculateDaysLeftProgressBar) name:UIApplicationWillEnterForegroundNotification object:nil];

      
    EZLog(@"View Did Load addDistanceViewController");

}


- (void)viewWillDisappear:(BOOL)animated
{

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self callDP:nil];
    return NO;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // must delloc from notification center or program will crash
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
    if (!addDistance) {
        return;
    }
    EZLog(@"addDistance = %.2f",addDistance);
    testDate = self.addRunDate;
    
    [[ShoeStore defaultStore] setRunDistance:addDistance];
    
    self.hist = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
    [distShoe addHistoryObject:hist];
    hist.runDistance = [NSNumber numberWithFloat:addDistance];
    EZLog(@"setting history run distance = %@",hist.runDistance);
    hist.runDate = testDate;
   
//    NSMutableArray *runDistances = [[NSMutableArray alloc] initWithArray:[distShoe.history allObjects]];
    
    EZLog(@"%@",hist.runDistance);
    
    runTotal = runTotal + addDistance;
    [totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];
    
    enterDistanceField.text = nil;
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
    totalDistanceProgress.progress = runTotal/distShoe.maxDistance.floatValue;
    
}


- (IBAction)callDP:(id)sender {
    
    [[self view] endEditing:YES];           // clear any editors that may be visible (clicking from distance to date)
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    pickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    pickerView.tag = 10;
    pickerView.datePickerMode = UIDatePickerModeDate;
//    [pickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [self.actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancelEZ:) forControlEvents:UIControlEventValueChanged];
    [self.actionSheet addSubview:closeButton];
    
    //[actionSheet showInView:self.view];
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)standardDistancesButtonPressed:(id)sender
{
    [[self view] endEditing:YES];           // clear any editors that may be visible
    
    StandardDistancesViewController *modalViewController = [[StandardDistancesViewController alloc] initWithDistance:self];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];

    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)runHistoryButtonPressed:(id)sender 
{
    [[self view] endEditing:YES];           // clear any editors that may be visible
    
    RunHistoryViewController *modalViewController = [[RunHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    modalViewController.shoe = distShoe;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
   
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)actionSheetCancelEZ:(id)sender
{
    EZLog(@"actionSHeetCancel");
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    EZLog(@"%@",[self.runDateFormatter stringFromDate:self.pickerView.date]);
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
    
    //  Need to strip out hours and seconds to avoid rounding errors on date calculation
    //  Define calendar to be used
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Set today's date to just yeay, month, day
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDate *date = [NSDate date];
    NSDateComponents *todayNoHoursNoSeconds = [gregorianCalendar components:unitFlags fromDate:date];
    
    // convert back to NSDate
    NSDate *today = [gregorianCalendar dateFromComponents:todayNoHoursNoSeconds];
    
    
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:today
                                                          toDate:distShoe.expirationDate
                                                         options:0];
    
    NSDateComponents *componentsTotal = [gregorianCalendar components:NSDayCalendarUnit
                                                             fromDate:distShoe.startDate
                                                               toDate:distShoe.expirationDate
                                                              options:0];
    
    NSInteger daysTotal = [componentsTotal day];
    NSInteger daysLeftToWear = ([components day]);
    float wear = 0.0;
    [daysLeftIdentificationLabel setText:@"Days Left"];
    [daysLeftLabel setText:@"0"];
    if (daysLeftToWear >= 0) {
        [daysLeftLabel setText:[NSString stringWithFormat:@"%d",daysLeftToWear]];
    }
    if (daysLeftToWear == 1) {
        [daysLeftIdentificationLabel setText:@"Day Left"];
    }
    
    EZLog(@"Components Total = %d",[components day]);
    
    wear = (float)daysLeftToWear/(float)daysTotal;
    wearProgress.progress = 1 - wear;
    EZLog(@"Wear Progress = %0.2f",wearProgress.progress);
    EZLog(@"Wear Days = %d and %d",daysLeftToWear, daysTotal);
    
    EZLog(@"Wear = %.4f",wear);

}

@end

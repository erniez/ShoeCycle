//
//  AddDistanceViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AddDistanceViewController.h"
#import "StandardDistancesViewController.h"
#import "RunHistoryViewController.h"
#import "ShoeStore.h"
#import "Shoe.h"
#import "History.h"
#import "UserDistanceSetting.h"
#import "RunShoeMileageAppDelegate.h"

float const milesToKilometers;
float runTotal;


@interface AddDistanceViewController ()

@property (weak, nonatomic) IBOutlet UIView *lightenView;

@end


@implementation AddDistanceViewController

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
    
    EZLog(@"History count = %d",[self.distShoe.history count]);
    
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
        self.distShoe = [shoes objectAtIndex:[UserDistanceSetting getSelectedShoe]];
    }
    else {
        self.distShoe = [shoes objectAtIndex:0];
    }
    
    runTotal = [self.distShoe.startDistance floatValue];
    if ([self.distShoe.history count]) {
        NSMutableArray *runs = [[NSMutableArray alloc] initWithArray:[self.distShoe.history allObjects]];
        NSInteger i = 0;
        do {
            History *tempHist = [runs objectAtIndex:i];
            runTotal = runTotal +  [tempHist.runDistance floatValue];
            EZLog (@"runDistance = %f",[tempHist.runDistance floatValue]);
            i++;
        } while (i < [self.distShoe.history count]);
        EZLog(@"run total = %f",runTotal);
    }
    
    self.nameField.text = [NSString stringWithFormat:@"%@",self.distShoe.brand];
    self.distanceUnitLabel.text = @"Miles";
    if ([UserDistanceSetting getDistanceUnit]) {
       self. distanceUnitLabel.text = @"Km";
    }
    self.totalDistanceProgress.progress = runTotal/self.distShoe.maxDistance.floatValue;
    [self.maxDistanceLabel setText:[NSString stringWithFormat:@"%@",[UserDistanceSetting displayDistance:[self.distShoe.maxDistance floatValue]]]];
    EZLog(@"run total2 = %f",runTotal);

    EZLog(@"run total3 = %f",runTotal);
    
    [self calculateDaysLeftProgressBar];
    
    [self.imageView setImage:[self.distShoe thumbnail]];

    EZLog(@"Leaving View Will Appear");
    EZLog(@"run total last = %f",runTotal);
    [self.totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];

}

- (void) viewDidAppear:(BOOL)animated
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_mamba"]];
    self.imageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.cornerRadius = 5.0;
    
    UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    arrowView.backgroundColor = [UIColor orangeColor];
    arrowView.transform = CGAffineTransformMakeRotation(M_PI/4);
    
    UIView *arrowContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    arrowContainer.clipsToBounds = YES;
    
    CGFloat yPosition = self.imageView.frame.origin.y + self.imageView.bounds.size.height;
    CGFloat xPosition = self.imageView.frame.origin.x +
                        self.imageView.bounds.size.width/2 -
                        arrowContainer.bounds.size.width/2;
    
    arrowView.center = CGPointMake(arrowContainer.bounds.size.width/2, -1);
    [arrowContainer addSubview:arrowView];
    
    CGRect containerFrame = arrowContainer.frame;
    containerFrame.origin.y = yPosition;
    containerFrame.origin.x = xPosition;
    arrowContainer.frame = containerFrame;
    
    [self.view addSubview:arrowContainer];
    
    self.lightenView.layer.cornerRadius = 5.0;
    
    self.enterDistanceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.enterDistanceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    if ([shoes count]) {
        if (([shoes count]-1) >= [UserDistanceSetting getSelectedShoe]){
            self.distShoe = [shoes objectAtIndex:[UserDistanceSetting getSelectedShoe]];
        }
        else {
            self.distShoe = [shoes objectAtIndex:0];
        }
    }
    
    self.nameField.text = self.distShoe.brand;
    
    self.runDateFormatter = [[NSDateFormatter alloc] init];
	[self.runDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.runDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.runDateField.delegate = self;
    EZLog(@"%@",[self.runDateFormatter stringFromDate:[NSDate date]]);
    self.addRunDate = [NSDate date];
    EZLog(@"run date = %@",self.addRunDate);
    [self.runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];

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
    NSManagedObjectContext *context = [self.distShoe managedObjectContext];
    NSDate *testDate; // temporary date that gets written to run history table
    
    // clear any editors that may be visible (clicking directly from distance number pad)
    [[self view] endEditing:YES];
    

    addDistance = [UserDistanceSetting enterDistance:[self.enterDistanceField text]];
    if (!addDistance) {
        return;
    }
    EZLog(@"addDistance = %.2f",addDistance);
    testDate = self.addRunDate;
    
    [[ShoeStore defaultStore] setRunDistance:addDistance];
    
    self.hist = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
    [self.distShoe addHistoryObject:self.hist];
    self.hist.runDistance = [NSNumber numberWithFloat:addDistance];
    EZLog(@"setting history run distance = %@",self.hist.runDistance);
    self.hist.runDate = testDate;
   
//    NSMutableArray *runDistances = [[NSMutableArray alloc] initWithArray:[distShoe.history allObjects]];
    
    EZLog(@"%@",self.hist.runDistance);
    
    runTotal = runTotal + addDistance;
    [self.totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];
    
    self.enterDistanceField.text = nil;
    [self.runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
    self.totalDistanceProgress.progress = runTotal/self.distShoe.maxDistance.floatValue;
    
}


- (IBAction)callDP:(id)sender {
    
    [[self view] endEditing:YES];           // clear any editors that may be visible (clicking from distance to date)
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    self.pickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    self.pickerView.tag = 10;
    self.pickerView.datePickerMode = UIDatePickerModeDate;
//    [pickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [self.actionSheet addSubview:self.pickerView];
    
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
    modalViewController.shoe = self.distShoe;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
   
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)actionSheetCancelEZ:(id)sender
{
    EZLog(@"actionSHeetCancel");
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    EZLog(@"%@",[self.runDateFormatter stringFromDate:self.pickerView.date]);
    self.addRunDate = self.pickerView.date;
    [self.runDateField setText:[self.runDateFormatter stringFromDate:self.pickerView.date]];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    RunShoeMileageAppDelegate *appDelegate = (RunShoeMileageAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToTab:1];
}


- (void)calculateDaysLeftProgressBar
{
    BOOL dateError = FALSE;
    NSComparisonResult result = [self.distShoe.expirationDate compare:self.distShoe.startDate];
    
    if (result == NSOrderedAscending) {
        dateError = TRUE;
    }
    [self.startDateLabel setText:[NSString stringWithFormat:@"%@",[self.runDateFormatter stringFromDate:self.distShoe.startDate]]];
    [self.expirationDateLabel setText:[NSString stringWithFormat:@"%@",[self.runDateFormatter stringFromDate:self.distShoe.expirationDate]]];
    if (dateError) {
        [self.expirationDateLabel setText:@" "];
        [self.startDateLabel setText:@"Your end date is earlier than your start date"];
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
                                                          toDate:self.distShoe.expirationDate
                                                         options:0];
    
    NSDateComponents *componentsTotal = [gregorianCalendar components:NSDayCalendarUnit
                                                             fromDate:self.distShoe.startDate
                                                               toDate:self.distShoe.expirationDate
                                                              options:0];
    
    NSInteger daysTotal = [componentsTotal day];
    NSInteger daysLeftToWear = ([components day]);
    float wear = 0.0;
    [self.daysLeftIdentificationLabel setText:@"Days Left"];
    [self.daysLeftLabel setText:@"0"];
    if (daysLeftToWear >= 0) {
        [self.daysLeftLabel setText:[NSString stringWithFormat:@"%d",daysLeftToWear]];
    }
    if (daysLeftToWear == 1) {
        [self.daysLeftIdentificationLabel setText:@"Day Left"];
    }
    
    EZLog(@"Components Total = %d",[components day]);
    
    wear = (float)daysLeftToWear/(float)daysTotal;
    self.wearProgress.progress = 1 - wear;
    EZLog(@"Wear Progress = %0.2f",self.wearProgress.progress);
    EZLog(@"Wear Days = %d and %d",daysLeftToWear, daysTotal);
    
    EZLog(@"Wear = %.4f",wear);

}

@end

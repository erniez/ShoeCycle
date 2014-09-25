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
#import "RunDatePickerViewController.h"

float const milesToKilometers;
float runTotal;


@interface AddDistanceViewController () <RunDatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *lightenView;
@property (nonatomic, strong) RunDatePickerViewController *runDatePickerViewController;

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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    EZLog(@"History count = %li",[self.distShoe.history count]);
    
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
    
    self.enterDistanceField.delegate = self;
    
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
    if (textField == self.runDateField)
    {
        [self callDP:textField];
        return NO;
    }
    else
    {
        [self dismissDatePickerIfShowing];
        return YES;
    }
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
    [self dismissDatePickerIfShowing];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissDatePickerIfShowing
{
    if (self.runDatePickerViewController)
    {
        [self dismissDatePicker:self.runDatePickerViewController];
    }
}

- (IBAction)addDistanceButton:(id)sender 
{
    float addDistance;
    
    [self dismissDatePickerIfShowing];

    
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
    
    [[self view] endEditing:YES];   // clear any editors that may be visible (clicking from distance to date)
    
    if (!self.runDatePickerViewController)
    {
        self.runDatePickerViewController = [[RunDatePickerViewController alloc] init];
        CGRect dpFrame = self.runDatePickerViewController.view.frame;
        dpFrame.origin.y = self.view.bounds.size.height;
        dpFrame.size.height = 250;
        self.runDatePickerViewController.view.frame = dpFrame;
        
        
        [self addChildViewController:self.runDatePickerViewController];
        [self.view addSubview:self.runDatePickerViewController.view];
        [self.runDatePickerViewController didMoveToParentViewController:self];
        
        self.runDatePickerViewController.delegate = self;
        
        dpFrame.origin.y -= self.runDatePickerViewController.view.bounds.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            self.runDatePickerViewController.view.frame = dpFrame;
        } completion:^(BOOL finished) {
            
        }];
    }

}

#pragma mark - RunDatePickerViewControllerDelegate

- (void)dismissDatePicker:(RunDatePickerViewController *)datePicker
{
    [self willMoveToParentViewController:nil];
    CGRect dpFrame = datePicker.view.frame;
    dpFrame.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        datePicker.view.frame = dpFrame;
    } completion:^(BOOL finished) {
        [datePicker.view removeFromSuperview];
        [datePicker removeFromParentViewController];
        self.runDatePickerViewController = nil;
    }];
}

- (void)runDatePickerValueDidChange:(NSDate *)newDate
{
    self.addRunDate = newDate;
    [self.runDateField setText:[self.runDateFormatter stringFromDate:newDate]];
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

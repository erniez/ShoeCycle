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
#import "ShoeCycleAppDelegate.h"
#import "RunDatePickerViewController.h"
#import "UIUtilities.h"
#import "HealthKitManager.h"
#import "UIColor+ShoeCycleColors.h"
#import "AFNetworking.h"
#import "StravaAPIManager.h"
#import "StravaActivity.h"
#import "ConnectionIconContainerView.h"
#import "UIView+Effects.h"
#import "UIAlertController+CommonAlerts.h"
#import "StravaActivity+DistanceConversion.h"
#import "MBProgressHUD.h"
#import "GlobalStringConstants.h"

float const milesToKilometers;
float runTotal;


@interface AddDistanceViewController () <RunDatePickerViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addDistanceButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBlockContstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBlockInnerConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *maxDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceUnitLabel;
@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, weak) IBOutlet UITextField *runDateField;
@property (nonatomic, strong) NSDateFormatter *runDateFormatter;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, strong) Shoe *distShoe;
@property (nonatomic, strong) History *hist;
@property (nonatomic, weak) IBOutlet UIProgressView *totalDistanceProgress;
@property (nonatomic, strong) NSDate *addRunDate;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *expirationDateLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftIdentificationLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *wearProgress;

@property (weak, nonatomic) IBOutlet UIView *lightenView;
@property (weak, nonatomic) IBOutlet ConnectionIconContainerView *iconContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageScrollIndicators;

// Have to use strong because I remove these views from superView in viewDidLoad.
// I do this, because I am using the nib to set up the views, rather than programatically.
@property (strong, nonatomic) IBOutlet UILabel *connectedToHealthKitAlert;
@property (strong, nonatomic) IBOutlet UIImageView *connectedToStravaView;

@property (nonatomic, strong) RunDatePickerViewController *runDatePickerViewController;
@property (nonatomic) BOOL noShoesInStore;
@property (nonatomic) BOOL writeToHealthKit;
@property (nonatomic) BOOL writeToStrava;

@property (nonatomic) NSArray *dataSource;

@end


@implementation AddDistanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        UIImage *image = [UIImage imageNamed:@"tabbar-add.png"];
        [tbi setTitle:@"Add Distance"];
        [tbi setImage:image];
    }
    return self;
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self loadDataSourceAndRefreshViews];
}

- (void)loadDataSourceAndRefreshViews
{
    self.dataSource = [[ShoeStore defaultStore] allShoes];
    
    if ([self.dataSource count] == 0)
    {
        self.noShoesInStore = YES;
        return;
    }
    else    // need the ELSE condition for when the user adds their initial shoe.
    {
        self.noShoesInStore = NO;
    }
    
    // Change sttings in prefix file to create a suitable screenshot for the first screen.
#ifdef LaunchImageSetup
    self.runDateField.text = @"";
    self.totalDistanceLabel.text = @"";
    self.expirationDateLabel.text = @"";
    self.startDateLabel.text = @"";
    self.daysLeftLabel.text = @"";
    self.maxDistanceLabel.text = @"";
    self.wearProgress.progress = 0.0;
    self.totalDistanceProgress.progress = 0.0;
    self.nameField.text = @"";
    self.distanceUnitLabel.text = @"";
    return;
#endif
    
    if (([self.dataSource count]-1) >= [UserDistanceSetting getSelectedShoe]){
        self.distShoe = [self.dataSource objectAtIndex:[UserDistanceSetting getSelectedShoe]];
    }
    else {
        self.distShoe = [self.dataSource objectAtIndex:0];
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
    
    if ([self.distShoe thumbnail]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setImage:[self.distShoe thumbnail]];
    }
    else {
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageView setImage:[UIImage imageNamed:@"photo-placeholder"]];
    }
    
    
    EZLog(@"Leaving View Will Appear");
    EZLog(@"run total last = %f",runTotal);
    [self.totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];
    self.writeToHealthKit = [UserDistanceSetting getHealthKitEnabled] && [self checkForHealthKit];
    self.writeToStrava = [UserDistanceSetting isStravaConnected];
    NSMutableArray *iconsToShow = [[NSMutableArray alloc] initWithCapacity:2];
    if (self.writeToHealthKit)
    {
        [iconsToShow addObject:self.connectedToHealthKitAlert];
    }
    if (self.writeToStrava) {
        [iconsToShow addObject:self.connectedToStravaView];
    }
    [self.iconContainerView setIconsToDisplay:[iconsToShow copy]];
}

- (BOOL)checkForHealthKit
{
    return [[HealthKitManager sharedManager] authorizationStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.noShoesInStore)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No shoes are being tracked:" message:@"You first need to add a shoe before you can add a distance." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            ShoeCycleAppDelegate *appDelegate = (ShoeCycleAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate switchToTab:1];
        }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.connectedToHealthKitAlert removeFromSuperview];
    [self.connectedToStravaView removeFromSuperview];
    self.iconContainerView.backgroundColor = [UIColor clearColor];
    
    if (![UIUtilities isIphone4ScreenSize])
    {
        self.bottomBlockContstraint.constant = 110;
        self.bottomBlockInnerConstraint.constant = 40;
    }
    
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
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
    self.imageView.layer.cornerRadius = 5.0;
    self.imageView.clipsToBounds = YES;
    
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
    
    [self.imageView addGestureRecognizer:[self newSwipeDownRecognizer]];
    [self.imageView addGestureRecognizer:[self newSwipeUpRecognizer]];
    [self.imageScrollIndicators addGestureRecognizer:[self newSwipeDownRecognizer]];
    [self.imageScrollIndicators addGestureRecognizer:[self newSwipeUpRecognizer]];
    
#ifdef SetupForScreenShots
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#endif
}

- (UISwipeGestureRecognizer *)newSwipeDownRecognizer
{
    UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageSwipe:)];
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    return swipeDownRecognizer;
}

- (UISwipeGestureRecognizer *)newSwipeUpRecognizer
{
    UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageSwipe:)];
    swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    return swipeUpRecognizer;
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
    addDistance = [UserDistanceSetting enterDistance:[self.enterDistanceField text]];
    if (!addDistance) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^addDistanceHandler)(void) = ^{
        
        
        [weakSelf dismissDatePickerIfShowing];
        
        NSManagedObjectContext *context = [weakSelf.distShoe managedObjectContext];
        NSDate *testDate; // temporary date that gets written to run history table
        
        // clear any editors that may be visible (clicking directly from distance number pad)
        [[weakSelf view] endEditing:YES];
        

        EZLog(@"addDistance = %.2f",addDistance);
        testDate = weakSelf.addRunDate;
        
        [[ShoeStore defaultStore] setRunDistance:addDistance];
        
        weakSelf.hist = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        [weakSelf.distShoe addHistoryObject:weakSelf.hist];
        weakSelf.hist.runDistance = [NSNumber numberWithFloat:addDistance];
        EZLog(@"setting history run distance = %@",weakSelf.hist.runDistance);
        weakSelf.hist.runDate = testDate;
        
        EZLog(@"%@",weakSelf.hist.runDistance);
        
        runTotal = runTotal + addDistance;
        [weakSelf.totalDistanceLabel setText:[UserDistanceSetting displayDistance:runTotal]];
        self.distShoe.totalDistance = @(runTotal);
        
        weakSelf.enterDistanceField.text = nil;
        [weakSelf.runDateField setText:[weakSelf.runDateFormatter stringFromDate:[NSDate date]]];
        weakSelf.totalDistanceProgress.progress = runTotal/weakSelf.distShoe.maxDistance.floatValue;
        
        if (weakSelf.writeToHealthKit)
        {
            NSURL *shoeIdenitfier = weakSelf.distShoe.objectID.URIRepresentation;
            NSString *shoeIDString = shoeIdenitfier.absoluteString;
            NSDictionary *metadata = @{@"ShoeCycleShoeIdentifier" : shoeIDString};
            [[HealthKitManager sharedManager] saveRunDistance:addDistance date:testDate metadata:metadata];
        }
        
        [weakSelf.iconContainerView.iconsToDisplay enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [view pulseView];
        }];
        
        [weakSelf.totalDistanceLabel pulseView];
        [[ShoeStore defaultStore] saveChangesEZ];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShoeDataDidChange object:nil];
    };
    if ([UserDistanceSetting isStravaConnected]) {
        [self showHUD];
        NSNumber *stravaDistance = [StravaActivity stravaDistanceFromAddDistance:addDistance];
        StravaActivity *activity = [[StravaActivity alloc] initWithName:@"ShoeCycle Logged Run" distance:stravaDistance startDate:[NSDate date]];
        [[StravaAPIManager new] sendActivityToStrava:activity completion:^(NSError *error) {
            [self hideHUD];
            if (error) {
                UIAlertController *alertController = [UIAlertController alertControllerWithOKButtonAndTitle:@"Network Connection Error" message:[NSString stringWithFormat:@"Sorry, there was a problem with the network connection. Details: %@",error.localizedDescription]];
                [weakSelf presentViewController:alertController animated:YES completion:nil];
            }
            else {
                addDistanceHandler();
            }
        }];
    }
    else {
        addDistanceHandler();
    }
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

- (void)handleImageSwipe:(UISwipeGestureRecognizer *)recognizer
{
    NSInteger selectedShoeIndex = [UserDistanceSetting getSelectedShoe];
    recognizer.direction == UISwipeGestureRecognizerDirectionUp ? selectedShoeIndex++ : selectedShoeIndex--;
    if (selectedShoeIndex < 0) {
        selectedShoeIndex = 0;
    }
    if (selectedShoeIndex > [self.dataSource count] - 1) {
        selectedShoeIndex = [self.dataSource count] - 1;
    }
    [UserDistanceSetting setSelectedShoe:selectedShoeIndex];
    [self loadDataSourceAndRefreshViews];
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
    
    RunHistoryViewController *modalViewController = [[RunHistoryViewController alloc] init];
    modalViewController.shoe = self.distShoe;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
   
    [self presentViewController:navController animated:YES completion:nil];
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
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Set today's date to just yeay, month, day
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDate *date = [NSDate date];
    NSDateComponents *todayNoHoursNoSeconds = [gregorianCalendar components:unitFlags fromDate:date];
    
    // convert back to NSDate
    NSDate *today = [gregorianCalendar dateFromComponents:todayNoHoursNoSeconds];
    
    
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:today
                                                          toDate:self.distShoe.expirationDate
                                                         options:0];
    
    NSDateComponents *componentsTotal = [gregorianCalendar components:NSCalendarUnitDay
                                                             fromDate:self.distShoe.startDate
                                                               toDate:self.distShoe.expirationDate
                                                              options:0];
    
    NSInteger daysTotal = [componentsTotal day];
    NSInteger daysLeftToWear = ([components day]);
    float wear = 0.0;
    [self.daysLeftIdentificationLabel setText:@"Days Left"];
    [self.daysLeftLabel setText:@"0"];
    if (daysLeftToWear >= 0) {
        [self.daysLeftLabel setText:[NSString stringWithFormat:@"%ld",(long)daysLeftToWear]];
    }
    if (daysLeftToWear == 1) {
        [self.daysLeftIdentificationLabel setText:@"Day Left"];
    }
    
    EZLog(@"Components Total = %ld",(long)[components day]);
    
    wear = (float)daysLeftToWear/(float)daysTotal;
    self.wearProgress.progress = 1 - wear;
    EZLog(@"Wear Progress = %0.2f",self.wearProgress.progress);
    EZLog(@"Wear Days = %ld and %ld",(long)daysLeftToWear, (long)daysTotal);
    
    EZLog(@"Wear = %.4f",wear);
}

- (void)showHUD
{
    if (![MBProgressHUD HUDForView:self.view]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.graceTime = 0.1;
        hud.minShowTime = 0.5;
        hud.activityIndicatorColor = [UIColor shoeCycleOrange];
        hud.labelText = @"Sending data to Strava ...";
        hud.labelColor = [UIColor shoeCycleOrange];
        hud.taskInProgress = YES;
        [self.view addSubview:hud];
        [hud show:YES];
    }
}

- (void)hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
@end

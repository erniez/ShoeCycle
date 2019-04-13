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
#import "Shoe+Helpers.h"
#import "History.h"
#import "UserDistanceSetting.h"
#import "ShoeCycleAppDelegate.h"
#import "RunDatePickerViewController.h"
#import "UIUtilities.h"
#import "HealthKitManager.h"
#import "UIColor+ShoeCycleColors.h"
#import <AFNetworking/AFNetworking.h>
#import "StravaAPIManager.h"
#import "StravaActivity.h"
#import "UIView+Effects.h"
#import "UIAlertController+CommonAlerts.h"
#import "StravaActivity+DistanceConversion.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GlobalStringConstants.h"
#import "AnalyticsLogger.h"
#import <Charts/Charts.h>
#import "ShoeCycle-Swift.h"


@interface AddDistanceViewController () <RunDatePickerViewDelegate, UIWebViewDelegate, IChartAxisValueFormatter, RunHistoryViewControllerDelegate>

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
@property (nonatomic, weak) IBOutlet UIProgressView *totalDistanceProgress;
@property (nonatomic, strong) NSDate *addRunDate;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *expirationDateLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftIdentificationLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *wearProgress;

@property (weak, nonatomic) IBOutlet UIView *lightenView;

@property (weak, nonatomic) IBOutlet UIStackView *statusIconsContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageScrollIndicators;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;

// Have to use strong because I remove these views from superView in viewDidLoad.
// I do this, because I am using the nib to set up the views, rather than programatically.
@property (strong, nonatomic) IBOutlet UILabel *connectedToHealthKitAlert;
@property (strong, nonatomic) IBOutlet UIImageView *connectedToStravaView;
@property (weak, nonatomic) IBOutlet UIView *arrowContainerView;

@property (nonatomic, strong) RunDatePickerViewController *runDatePickerViewController;
@property (nonatomic) BOOL noShoesInStore;
@property (nonatomic) BOOL writeToHealthKit;
@property (nonatomic) BOOL writeToStrava;

@property (nonatomic) NSArray *dataSource;
@property (weak, nonatomic) AnalyticsLogger *logger;
@property (nonatomic) UITapGestureRecognizer *shoeImageTapRecognizer;

@property (nonatomic, strong) LineChartDataSet *dataSet;
@property (nonatomic, strong) ChartLimitLine *chartLimitLine;
@property (nonatomic, strong) NSArray<WeeklyCollated *> *weeklyCollatedArray;
@property (nonatomic) BOOL animateChart;

@property (nonatomic, strong) ImagePickerDelegate *imagePickerDelegate;

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

- (void)loadDataSourceAndRefreshViewAndChart
{
    [self loadDataSourceAndRefreshViews];
    [self refreshChart];
}

- (void)loadDataSourceAndRefreshViews
{
    self.dataSource = [[ShoeStore defaultStore] activeShoes];
    
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
    
    self.nameField.text = [NSString stringWithFormat:@"%@",self.distShoe.brand];
    self.distanceUnitLabel.text = [UserDistanceSetting unitOfMeasure];
    self.totalDistanceProgress.progress = self.distShoe.totalDistance.floatValue/self.distShoe.maxDistance.floatValue;
    [self.maxDistanceLabel setText:[NSString stringWithFormat:@"%@",[UserDistanceSetting displayDistance:[self.distShoe.maxDistance floatValue]]]];
    
    [self calculateDaysLeftProgressBar];
    
    if ([self.distShoe thumbnail]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setImage:[self.distShoe thumbnail]];
        self.shoeImageTapRecognizer.enabled = NO;
    }
    else {
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageView setImage:[UIImage imageNamed:@"photo-placeholder"]];
        self.shoeImageTapRecognizer.enabled = YES;
    }

    [self.totalDistanceLabel setText:[UserDistanceSetting displayDistance:self.distShoe.totalDistance.floatValue]];
    self.writeToHealthKit = [UserDistanceSetting getHealthKitEnabled] && [self checkForHealthKit];
    self.writeToStrava = [UserDistanceSetting isStravaConnected];
    if (self.writeToHealthKit)
    {
        [self.statusIconsContainerView addArrangedSubview:self.connectedToHealthKitAlert];
    }
    if (self.writeToStrava) {
        [self.statusIconsContainerView addArrangedSubview:self.connectedToStravaView];
    }
}

- (void)refreshChart
{
    [self updateChartData];
    if (self.animateChart) {
        [self.lineChartView animateWithYAxisDuration:1.0];
        self.animateChart = NO;
    }
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
    [self refreshChart]; // The chart doesn't know it's entire layout until AFTER view will appear.
    // reset no data text from empty.
    self.lineChartView.noDataText = @"Please enter a run distance to see data in this graph.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logger = [AnalyticsLogger sharedLogger];
    
    self.shoeImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shoeImageTapped:)];
    
    [self.connectedToHealthKitAlert removeFromSuperview];
    [self.connectedToStravaView removeFromSuperview];
    
    if (![UIUtilities isIphone4ScreenSize])
    {
        self.bottomBlockContstraint.constant = 110;
        self.bottomBlockInnerConstraint.constant = 40;
    }
    
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    self.imageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.cornerRadius = 5.0;
    
    UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    arrowView.backgroundColor = [UIColor orangeColor];
    arrowView.transform = CGAffineTransformMakeRotation(M_PI/4);
    
    self.arrowContainerView.clipsToBounds = YES;
    self.arrowContainerView.backgroundColor = UIColor.clearColor;
    
    arrowView.center = CGPointMake(self.arrowContainerView.bounds.size.width/2, 0);
    [self.arrowContainerView addSubview:arrowView];
    
    self.lightenView.layer.cornerRadius = 5.0;
    self.imageView.layer.cornerRadius = 5.0;
    self.imageView.clipsToBounds = YES;
    
    self.enterDistanceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.enterDistanceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    self.enterDistanceField.delegate = self;
    
    NSArray *shoes = [[ShoeStore defaultStore] activeShoes];
    
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
    
    self.swipeView.backgroundColor = [UIColor clearColor];
    [self.swipeView addGestureRecognizer:[self newSwipeDownRecognizer]];
    [self.swipeView addGestureRecognizer:[self newSwipeUpRecognizer]];
    [self.swipeView addGestureRecognizer:self.shoeImageTapRecognizer];

    // iPhoneSE cannot fit the graph, so remove it.
    if ([UIUtilities isSmallScreenSize]) {
        [self.lineChartView removeFromSuperview];
    }
    [self configureLineChartView];
    self.animateChart = YES;
    
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

- (void)configureLineChartView
{
    self.lineChartView.xAxis.labelTextColor = [UIColor whiteColor];
    self.lineChartView.legend.textColor = [UIColor whiteColor];
    self.lineChartView.xAxis.valueFormatter = self;
    self.lineChartView.leftAxis.labelTextColor = [UIColor whiteColor];
    self.lineChartView.leftAxis.drawGridLinesEnabled = NO;
    self.lineChartView.leftAxis.axisMinimum = 0.0;
    self.lineChartView.leftAxis.granularityEnabled = YES;
    self.lineChartView.leftAxis.spaceTop = 0.25;
    self.lineChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    self.lineChartView.xAxis.drawGridLinesEnabled = NO;
    self.lineChartView.xAxis.granularityEnabled = YES;
    self.lineChartView.rightAxis.enabled = NO;
    self.lineChartView.minOffset = 24.0; // Need to do this because dates were getting cut off.
    self.lineChartView.scaleYEnabled = NO;
    self.lineChartView.scaleXEnabled = NO;
    self.lineChartView.noDataTextColor = [UIColor whiteColor];
    self.lineChartView.noDataFont = [UIFont systemFontOfSize:16.0];
    // Set no data text to empty to prevent it from flashing on the screen before view did appear.
    self.lineChartView.noDataText = @"";
    
    self.chartLimitLine = [ChartLimitLine new];
    self.chartLimitLine.lineColor = [UIColor shoeCycleBlue];
    self.chartLimitLine.lineDashLengths = @[[NSNumber numberWithDouble:10.0], [NSNumber numberWithDouble:5.0]];
    [self.lineChartView.leftAxis addLimitLine:self.chartLimitLine];
}

- (void)updateChartData
{
    self.lineChartView.data = nil;
    self.dataSet = [LineChartDataSet new];
    [self configureDataSet];
    self.weeklyCollatedArray = [self.distShoe collatedRunHistoryByWeekAscending:YES];
    [self.weeklyCollatedArray enumerateObjectsUsingBlock:^(WeeklyCollated * _Nonnull weeklyCollated, NSUInteger idx, BOOL * _Nonnull stop) {
        float runDistance = [UserDistanceSetting getDistanceFromMiles:[weeklyCollated.runDistance floatValue]];
        double value = (double)runDistance;
        ChartDataEntry *dataEntry = [[ChartDataEntry alloc] initWithX:idx y:value];
        if (![self.dataSet addEntry:dataEntry]) {
            *stop = YES;
        }
    }];

    if (self.weeklyCollatedArray.count > 0) {
        self.lineChartView.data = [[LineChartData alloc] initWithDataSet:self.dataSet];
        self.chartLimitLine.limit = self.dataSet.yMax;
        // only show 12 datapoints at a time.
        [self.lineChartView setVisibleXRangeMaximum:11];
        // move the chart to show the latest values.
        [self.lineChartView moveViewToX:self.dataSet.entryCount];
    }
}

- (void)configureDataSet
{
    self.dataSet.circleRadius = 3.0;
    self.dataSet.drawCircleHoleEnabled = NO;
    self.dataSet.circleColor = [UIColor shoeCycleGreen];
    self.dataSet.circleHoleColor = [UIColor shoeCycleBlue];
    self.dataSet.color = [UIColor shoeCycleOrange];
    self.dataSet.drawValuesEnabled = NO;
    self.dataSet.label = [UserDistanceSetting unitOfMeasure];
}

- (NSString * _Nonnull)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis
{
    if (self.weeklyCollatedArray.count <= value || value < 0 ) {
        return @"";
    }
    WeeklyCollated *weeklyCollated = self.weeklyCollatedArray[(int)value];
    return [self.runDateFormatter stringFromDate:weeklyCollated.date];
}

- (NSArray *)createZeroChartData
{
    NSMutableArray *zeroData = [NSMutableArray new];
    for (int i = 1; i <= 12; i++) {
        ChartDataEntry *dataEntry = [[ChartDataEntry alloc] initWithX:i y:0.0];
        [zeroData addObject:dataEntry];
    }
    return [zeroData copy];
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
    [self dismissDatePicker:self.runDatePickerViewController completion:nil];
}

- (void)dismissDatePickerIfShowingWithCompletion:(void(^)(void))completion
{
    if (self.runDatePickerViewController)
    {
        [self dismissDatePicker:self.runDatePickerViewController completion:completion];
    }
    else {
        if (completion) {
            completion();
        }
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
       
        NSManagedObjectContext *context = [weakSelf.distShoe managedObjectContext];
        NSDate *testDate; // temporary date that gets written to run history table
        
        // clear any editors that may be visible (clicking directly from distance number pad)
        [[weakSelf view] endEditing:YES];

        EZLog(@"addDistance = %.2f",addDistance);
        testDate = weakSelf.addRunDate;
    
        History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        history.runDistance = [NSNumber numberWithFloat:addDistance];
        history.runDate = testDate;
        [weakSelf.distShoe addHistoryObject:history];
        
        [[ShoeStore defaultStore] updateTotalDistanceForShoe:weakSelf.distShoe];
        [[ShoeStore defaultStore] saveChangesEZ];
        
        weakSelf.enterDistanceField.text = nil;
        weakSelf.totalDistanceProgress.progress = self.distShoe.totalDistance.floatValue/weakSelf.distShoe.maxDistance.floatValue;
        
        if (weakSelf.writeToHealthKit)
        {
            NSURL *shoeIdenitfier = weakSelf.distShoe.objectID.URIRepresentation;
            NSString *shoeIDString = shoeIdenitfier.absoluteString;
            NSDictionary *metadata = @{@"ShoeCycleShoeIdentifier" : shoeIDString};
            [self.logger logEventWithName:kHealthKitEvent userInfo:nil];
            [[HealthKitManager sharedManager] saveRunDistance:addDistance date:testDate metadata:metadata];
        }
        
        [weakSelf dismissDatePickerIfShowingWithCompletion:^{
            [weakSelf.totalDistanceLabel setText:[UserDistanceSetting displayDistance:[weakSelf.distShoe.totalDistance floatValue]]];
            [weakSelf.totalDistanceLabel pulseView];
            [self.logger logEventWithName:kLogMileageEvent userInfo:@{kMileageNumberKey : @(addDistance)}];
            [self.logger logEventWithName:kLogTotalMileageEvent userInfo:@{kTotalMileageNumberKey : @(self.distShoe.totalDistance.floatValue)}];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoeDataDidChange object:nil];
        }];
        
        self.animateChart = YES;
        [self refreshChart];
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
                [self.logger logEventWithName:kStravaEvent userInfo:nil];
                addDistanceHandler();
            }
        }];
    }
    else {
        addDistanceHandler();
    }
}


- (IBAction)callDP:(id)sender
{
    [[self view] endEditing:YES];   // clear any editors that may be visible (clicking from distance to date)
    
    if (!self.runDatePickerViewController)
    {
        self.runDatePickerViewController = [[RunDatePickerViewController alloc] init];
        
        NSDate *datePickerDate = [NSDate date];
        if (self.runDateField.text.length > 0) {
            datePickerDate = [self.runDateFormatter dateFromString:self.runDateField.text];
        }
        [self.runDatePickerViewController setDate:datePickerDate];
        
        UIView *dpView = self.runDatePickerViewController.view;
        dpView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController:self.runDatePickerViewController];
        [self.view addSubview:self.runDatePickerViewController.view];
        [self.runDatePickerViewController didMoveToParentViewController:self];
        
        [dpView.heightAnchor constraintEqualToConstant:250.0].active = YES;
        [dpView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [dpView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        NSLayoutConstraint *bottomConstraint = [dpView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:250.0];
        bottomConstraint.active = YES;
        [self.view layoutIfNeeded];
        
        self.runDatePickerViewController.delegate = self;
     
        [UIView animateWithDuration:0.5 animations:^{
            bottomConstraint.constant = 0.0;
            [self.view layoutIfNeeded];
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
    self.animateChart = YES;
    [self loadDataSourceAndRefreshViewAndChart];
}

#pragma mark - RunDatePickerViewControllerDelegate

- (void)dismissDatePicker:(RunDatePickerViewController *)datePicker
{
    [self dismissDatePicker:datePicker completion:nil];
}

- (void)dismissDatePicker:(RunDatePickerViewController *)datePicker completion:(void(^)(void))completion
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
        if (completion) {
            completion();
        }
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
    [self dismissDatePickerIfShowing];
    
    StandardDistancesViewController *modalViewController = [[StandardDistancesViewController alloc] initWithDistance:self];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];

    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)runHistoryButtonPressed:(id)sender 
{
    [[self view] endEditing:YES];           // clear any editors that may be visible
    [self dismissDatePickerIfShowing];
    
    RunHistoryViewController *modalViewController = [[RunHistoryViewController alloc] init];
    modalViewController.shoe = self.distShoe;
    modalViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
   
    [self.logger logEventWithName:kShowHistoryEvent userInfo:nil];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)shoeImageTapped:(id)send
{
    NSLog(@"shoe tapped");
    self.imagePickerDelegate = [[ImagePickerDelegate alloc] initWithShoe:self.distShoe];
    __weak typeof(self) weakSelf = self;
    [self.imagePickerDelegate setOnDidFinishPicking:^(UIImage * _Nullable image) {
        weakSelf.imageView.image = image;
        [[ShoeStore defaultStore] saveChangesEZ];
    }];
    [self.imagePickerDelegate presentImagePickerAlertViewControllerWithPresentingViewController:self];
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
    
    // Set today's date to just year, month, day
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
        hud.label.text = @"Sending data to Strava ...";
        hud.label.textColor = [UIColor shoeCycleOrange];
        [self.view addSubview:hud];
        [hud showAnimated:YES];
    }
}

- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma RunHistoryViewControllerDelegate
- (void)runHistoryDidChangeWithShoe:(Shoe *)shoe
{
    self.animateChart = YES;
}

@end

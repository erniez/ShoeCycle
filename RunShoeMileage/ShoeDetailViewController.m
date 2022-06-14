//
//  ShoeDetailViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShoeDetailViewController.h"
#import "ShoeStore.h"
#import "ImageStore.h"
#import "UserDistanceSetting.h"
#import "UIColor+ShoeCycleColors.h"
#import "UIUtilities.h"
#import "RunDatePickerViewController.h"
#import "GlobalStringConstants.h"
#import "AnalyticsLogger.h"
#import "ShoeCycle-Swift.h"


@interface ShoeDetailViewController () <RunDatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *hallOfFameButton;
@property (weak, nonatomic) IBOutlet UIView *shoeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *distanceBackroundView;
@property (weak, nonatomic) IBOutlet UIView *wearBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *shoeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wearTimeTitleLabel;
@property (nonatomic, strong) RunDatePickerViewController *runDatePickerViewController;
// Have to retain the imagePickerDelegate as its own property, or else it will crash when you rotate after taking a picture.
// The crash is caused by notification sender sending the imagePicker a rotation notification, and it not being around
// to process it, getting an unrecogized selector error.
@property (nonatomic, strong) ImagePickerDelegate *imagePickerDelegate;

@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL newShoeIsCancelled;

@end

@implementation ShoeDetailViewController

const CGFloat TAB_BAR_HEIGHT = 49;

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"ShoeDetailViewController" bundle:nil];
    
    if (self) {
        if (isNew) {
            _isNew = isNew;
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                         target:self 
                                         action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                           target:self
                                           action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
            
            self.maxDistance.text = @"350";
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isNew)
    {
        [self configureToolbar];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.newShoeIsCancelled)
    {
        [super viewWillDisappear:animated];
        self.shoe.brand = self.brandField.text;
        self.shoe.maxDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.maxDistance.text]];
        EZLog(@"Leaving maxDistance %@",self.shoe.maxDistance);
        self.shoe.startDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.startDistance.text]];
        self.shoe.expirationDate = self.expirationDate;
        self.shoe.startDate = self.startDate;
        [[ShoeStore defaultStore] updateTotalDistanceForShoe:self.shoe];
        
        // Save changes, if any, unless cancelled (new shoe only)
        [[ShoeStore defaultStore] saveChangesEZ];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    
    self.maxDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.maxDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    self.startDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.startDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    self.shoeTitleLabel.textColor = [UIColor shoeCycleOrange];
    self.distanceTitleLabel.textColor = [UIColor shoeCycleGreen];
    self.wearTimeTitleLabel.textColor = [UIColor shoeCycleBlue];
    
    self.shoeBackgroundView.layer.borderColor = [UIColor shoeCycleOrange].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.shoeBackgroundView];
    
    self.distanceBackroundView.layer.borderColor = [UIColor shoeCycleGreen].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.distanceBackroundView];
    
    self.wearBackgroundView.layer.borderColor = [UIColor shoeCycleBlue].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.wearBackgroundView];
    
    // Create dotted lines
    CGRect lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.shoeBackgroundView.bounds.size.height);
    UIView *lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleOrange]];
    [self.shoeBackgroundView addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.distanceBackroundView.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleGreen]];
    [self.distanceBackroundView addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.wearBackgroundView.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleBlue]];
    [self.wearBackgroundView addSubview:lineView];
    
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture:)];
    [self.imageView addGestureRecognizer:photoTap];
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [UIColor shoeCycleOrange].CGColor;
    self.imageView.layer.cornerRadius = 7.0;
    
    NSString *imageKey = [self.shoe imageKey];
    
    if (imageKey) {
        // Get image for image key from image store
        UIImage *imageToDisplay = [[ImageStore defaultImageStore] imageForKey:imageKey];
        
        // Use that image to put on the screen in imageView
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setImage:imageToDisplay];
    } else {
        // Clear the imageView
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self.imageView setImage:[UIImage imageNamed:@"photo-placeholder"]];
    }
    
    [self configureView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/* ==============================================================
 End View Lifecycle
 =============================================================== */

- (void)configureView
{
    [self.brandField setText:self.shoe.brand];
    
    [self.maxDistance setText:[UserDistanceSetting displayDistance:[self.shoe.maxDistance floatValue]]];
    [self.startDistance setText:[UserDistanceSetting displayDistance:[self.shoe.startDistance floatValue]]];
    
    self.expirationDateFormatter = [[NSDateFormatter alloc] init];
    [self.expirationDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.expirationDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.expirationDate = self.shoe.expirationDate;
    [self.expirationDateField setText:[self.expirationDateFormatter stringFromDate:self.shoe.expirationDate]];
    self.startDate = self.shoe.startDate;
    [self.startDateField setText:[self.expirationDateFormatter stringFromDate:self.shoe.startDate]];
    EZLog(@"Will Appear Date = %@",self.shoe.expirationDate);
    [self updateHallOfFameButtonText];
}

- (void)configureToolbar
{
    if (!self.toolbar) {
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:@selector(takePicture:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
        
        NSArray *items = [NSArray arrayWithObjects:camera, spacer, nil];
        
        self.toolbar = [UIToolbar new];
        self.toolbar.barStyle = UIBarStyleDefault;

        [self.toolbar setItems:items animated:YES];
        
        self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.toolbar];
        [self.toolbar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:0.0].active = YES;
        [self.toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0.0].active = YES;
        [self.toolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0].active = YES;
    }
}

// ==========================================================================================
// dismiss keyboards
// ==========================================================================================

- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// ==========================================================================================
// end dismiss keyboards
// ==========================================================================================


- (IBAction)takePicture:(id)sender
{
    self.imagePickerDelegate = [[ImagePickerDelegate alloc] initWithShoe:self.shoe];
    __weak typeof(self) weakSelf = self;
    [self.imagePickerDelegate setOnDidFinishPicking:^(UIImage * _Nullable image) {
        weakSelf.imageView.image = image;
    }];
    [self.imagePickerDelegate presentImagePickerAlertViewControllerWithPresentingViewController:self];
}

- (IBAction)save:(id)sender
{
    self.shoe.brand = self.brandField.text;
            
    EZLog(@"%@", self.shoe.brand);
    
    [[ShoeStore defaultStore] saveChangesEZ];
    
    // This message gets forwarded to the parentViewController  
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the Possession from the store
    // This message gets forwarded to the parentViewController

    [[ShoeStore defaultStore] removeShoe:self.shoe];
    self.newShoeIsCancelled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)callDP:(id)sender
{
    [[self view] endEditing:YES];   // clear any editors that may be visible (clicking from distance to date)
    
    self.currentDateField = sender;
    
    if (!self.runDatePickerViewController)
    {
        self.runDatePickerViewController = [[RunDatePickerViewController alloc] init];
        CGRect dpFrame = self.runDatePickerViewController.view.frame;
        dpFrame.origin.y = self.view.bounds.size.height;
        dpFrame.size.width = UIScreen.mainScreen.bounds.size.width;
        dpFrame.size.height = 250;
        self.runDatePickerViewController.view.frame = dpFrame;
        
        [self addChildViewController:self.runDatePickerViewController];
        [self.view addSubview:self.runDatePickerViewController.view];
        [self.runDatePickerViewController didMoveToParentViewController:self];
        
        self.runDatePickerViewController.delegate = self;
        
        dpFrame.origin.y -= (self.runDatePickerViewController.view.bounds.size.height + TAB_BAR_HEIGHT);
        [UIView animateWithDuration:0.5 animations:^{
            self.runDatePickerViewController.view.frame = dpFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    [self.runDatePickerViewController setDate:self.currentDate];
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
    if (self.currentDateField == self.startDateField){
        self.startDate = newDate;
    }
    
    if (self.currentDateField == self.expirationDateField) {
        self.expirationDate = newDate;
    }
    [self.currentDateField setText:[self.expirationDateFormatter stringFromDate:newDate]];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.expirationDateField) {
        self.currentDate = self.expirationDate;
        [self callDP:self.expirationDateField];
        return NO;
    }
    
    if (textField == self.startDateField) {
        self.currentDate = self.startDate;
        [self callDP:self.startDateField];
        return NO;
    }
    
    return YES;    
}

- (IBAction)didTapHallOfFameButton:(id)sender
{
    self.shoe.hallOfFame = !self.shoe.hallOfFame;
    if (self.shoe.hallOfFame) {
        [[AnalyticsLogger sharedLogger] logEventWithName:kRemoveFromHOFEvent userInfo:nil];
    }
    else {
        [[AnalyticsLogger sharedLogger] logEventWithName:kAddToHOFEvent userInfo:nil];
    }
    [self updateHallOfFameButtonText];
}

- (void)updateHallOfFameButtonText
{
    [UIView animateWithDuration:0.25 animations:^{
        if (self.shoe.hallOfFame) {
            [self.hallOfFameButton setTitle:@"Remove from Hall of Fame" forState:UIControlStateNormal];
        }
        else {
            [self.hallOfFameButton setTitle:@"Add to Hall of Fame" forState:UIControlStateNormal];
        }
        [self.view layoutIfNeeded];
    }];
}
@end

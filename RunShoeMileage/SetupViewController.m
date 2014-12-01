//
//  SetupViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import "RunShoeMileageAppDelegate.h"
#import "UserDistanceSetting.h"
#import "UIColor+ShoeCycleColors.h"
#import "UIUtilities.h"
#import "HealthKitManager.h"


@interface SetupViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *distanceUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *userDefinedDistance1;
@property (weak, nonatomic) IBOutlet UITextField *userDefinedDistance2;
@property (weak, nonatomic) IBOutlet UITextField *userDefinedDistance3;
@property (weak, nonatomic) IBOutlet UITextField *userDefinedDistance4;

@property (weak, nonatomic) IBOutlet UIView *unitsBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *favoriteDistancesBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *unitsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDistancesTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *enableHealthKitBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *enableHealthKitLabel;
@property (weak, nonatomic) IBOutlet UILabel *enableHealthKitInfoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableHealthKitSwitch;

@end

@implementation SetupViewController

- (id)init
{
    // Call the class designated initializer
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
//        int offset = 7;
//        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
        
        // Give it a centered icon
 //       tbi.imageInsets = imageInset;
        UIImage *image = [UIImage imageNamed:@"tabbar-gear.png"];
        [tbi setTitle:@"Setup"];
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

    EZLog(@"entering setupViewController Memory warning");
    [super didReceiveMemoryWarning];
    EZLog(@"leaving setupViewController Memory warning");
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_mamba"]];
    self.unitsTitleLabel.textColor = [UIColor shoeCycleOrange];
    self.favDistancesTitleLabel.textColor = [UIColor shoeCycleGreen];
    self.enableHealthKitLabel.textColor = [UIColor shoeCycleBlue];
    self.enableHealthKitInfoLabel.textColor = [UIColor shoeCycleOrange];
    
    self.userDefinedDistance1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.userDefinedDistance1.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    self.userDefinedDistance2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.userDefinedDistance2.keyboardType = UIKeyboardTypeDecimalPad;
    }

    self.userDefinedDistance3.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.userDefinedDistance3.keyboardType = UIKeyboardTypeDecimalPad;
    }

    self.userDefinedDistance4.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.userDefinedDistance4.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    self.userDefinedDistance1.delegate = self;
    self.userDefinedDistance2.delegate = self;
    self.userDefinedDistance3.delegate = self;
    self.userDefinedDistance4.delegate = self;

    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    
    self.unitsBackgroundView.layer.borderColor = [UIColor shoeCycleOrange].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.unitsBackgroundView];
    
    self.favoriteDistancesBackgroundView.layer.borderColor = [UIColor shoeCycleGreen].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.favoriteDistancesBackgroundView];
    
    self.enableHealthKitBackgroundView.layer.borderColor = [UIColor shoeCycleBlue].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.enableHealthKitBackgroundView];
    
    // Create dotted lines
    CGRect lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.unitsBackgroundView.bounds.size.height);
    UIView *lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleOrange]];
    [self.unitsBackgroundView addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.favoriteDistancesBackgroundView.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleGreen]];
    [self.favoriteDistancesBackgroundView addSubview:lineView];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.distanceUnitControl setSelectedSegmentIndex:[UserDistanceSetting getDistanceUnit]];
    [self refreshUserDefinedDistances];
    [self.enableHealthKitSwitch setOn:[UserDistanceSetting getHealthKitEnabled] animated:NO];
    [self updateEnableHealthKitInfoLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


- (void)refreshUserDefinedDistances
{
    if ([UserDistanceSetting getUserDefinedDistance1]) {
        [self.userDefinedDistance1 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance2]) {
        [self.userDefinedDistance2 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance3]) {
        [self.userDefinedDistance3 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance4]) {
        [self.userDefinedDistance4 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]]];
    }

}

- (IBAction)aboutButton:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"About ShoeCycle" message:@"ShoeCycle is programmed by Ernie Zappacosta.\nCurrent Version is 2.2" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.userDefinedDistance1) {
        float distance = [UserDistanceSetting enterDistance:self.userDefinedDistance1.text];
        [UserDistanceSetting setUserDefinedDistance1:distance];
    }
    if (textField == self.userDefinedDistance2) {
        float distance = [UserDistanceSetting enterDistance:self.userDefinedDistance2.text];
        [UserDistanceSetting setUserDefinedDistance2:distance];
    }
    if (textField == self.userDefinedDistance3) {
        float distance = [UserDistanceSetting enterDistance:self.userDefinedDistance3.text];
        [UserDistanceSetting setUserDefinedDistance3:distance];
    }
    if (textField == self.userDefinedDistance4) {
        float distance = [UserDistanceSetting enterDistance:self.userDefinedDistance4.text];
        [UserDistanceSetting setUserDefinedDistance4:distance];
    }

    return YES;
}


- (IBAction)changeDistanceUnits:(id)sender 
{
    [UserDistanceSetting setDistanceUnit:[sender selectedSegmentIndex]];
    [self refreshUserDefinedDistances];
}

- (IBAction)enableHealthKitValueDidChange:(id)sender
{
    UISwitch *enableSwitch = sender;
    HealthKitManager *healthManager = [HealthKitManager sharedManager];

    [UserDistanceSetting setHealthKitEnabled:enableSwitch.isOn];
    
    if (healthManager.authorizationStatus != HKAuthorizationStatusSharingAuthorized && enableSwitch.isOn)
    {
        [healthManager initializeHealthKitForShoeCycleWithCompletion:^(BOOL success, UIAlertController *alertController) {
            if (success)
            {
                [self updateEnableHealthKitInfoLabel];
            }
            else
            {
                if (alertController)
                {
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                // User denied us access so we need to reset the switch
                [UserDistanceSetting setHealthKitEnabled:NO];
                // Not guaranteed to be on main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [enableSwitch setOn:NO animated:YES];
                });
            }
        }];
    }
    else
    {
        [self updateEnableHealthKitInfoLabel];
    }
}

- (void)updateEnableHealthKitInfoLabel
{
    if ([UserDistanceSetting getHealthKitEnabled])
    {
        self.enableHealthKitInfoLabel.text = @"Turning this option on will write directly to the Walk + Run Section of the Health App. The ❤️ means that you're connected.";
    }
    else
    {
        self.enableHealthKitInfoLabel.text = @"Turning this option on will write directly to the Walk + Run Section of the Health App.";
    }
}
@end

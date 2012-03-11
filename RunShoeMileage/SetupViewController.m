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

//extern NSInteger distanceUnit;

@implementation SetupViewController
@synthesize distanceUnitControl;
@synthesize userDefinedDistance1;
@synthesize userDefinedDistance2;
@synthesize userDefinedDistance3;
@synthesize userDefinedDistance4;


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
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefinedDistance1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        userDefinedDistance1.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    userDefinedDistance2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        userDefinedDistance2.keyboardType = UIKeyboardTypeDecimalPad;
    }

    userDefinedDistance3.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        userDefinedDistance3.keyboardType = UIKeyboardTypeDecimalPad;
    }

    userDefinedDistance4.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        userDefinedDistance4.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    userDefinedDistance1.delegate = self;
    userDefinedDistance2.delegate = self;
    userDefinedDistance3.delegate = self;
    userDefinedDistance4.delegate = self;

    
    // Do any additional setup after loading the view from its nib.
}


-(void) viewWillAppear:(BOOL)animated
{
    [distanceUnitControl setSelectedSegmentIndex:[UserDistanceSetting getDistanceUnit]];
    [self refreshUserDefinedDistances];
}

- (void)viewDidUnload
{
    [self setDistanceUnitControl:nil];
    [self setUserDefinedDistance1:nil];
    [self setUserDefinedDistance2:nil];
    [self setUserDefinedDistance3:nil];
    [self setUserDefinedDistance4:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
//    NSLog(@"Made it to textFieldShouldReturn");
    return YES;
}

// ==========================================================================================
// end dismiss keyboards
// ==========================================================================================


- (void)refreshUserDefinedDistances
{
    if ([UserDistanceSetting getUserDefinedDistance1]) {
        [userDefinedDistance1 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance2]) {
        [userDefinedDistance2 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance3]) {
        [userDefinedDistance3 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]]];
    }
    if ([UserDistanceSetting getUserDefinedDistance4]) {
        [userDefinedDistance4 setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]]];
    }

}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
//    NSLog(@"Should End Editing: %@",textField.text);
    if (textField == userDefinedDistance1) {
        float distance = [UserDistanceSetting enterDistance:userDefinedDistance1.text];
        [UserDistanceSetting setUserDefinedDistance1:distance];
//        NSLog(@"Favorite Distance 1 = %.2f",distance);
    }
    if (textField == userDefinedDistance2) {
        float distance = [UserDistanceSetting enterDistance:userDefinedDistance2.text];
        [UserDistanceSetting setUserDefinedDistance2:distance];
//        NSLog(@"Favorite Distance 2 = %.2f",distance);
    }
    if (textField == userDefinedDistance3) {
        float distance = [UserDistanceSetting enterDistance:userDefinedDistance3.text];
        [UserDistanceSetting setUserDefinedDistance3:distance];
//        NSLog(@"Favorite Distance 3 = %.2f",distance);
    }
    if (textField == userDefinedDistance4) {
        float distance = [UserDistanceSetting enterDistance:userDefinedDistance4.text];
        [UserDistanceSetting setUserDefinedDistance4:distance];
//        NSLog(@"Favorite Distance 4 = %.2f",distance);
    }

    return YES;
}


- (IBAction)changeDistanceUnits:(id)sender 
{
    [UserDistanceSetting setDistanceUnit:[sender selectedSegmentIndex]];
    [self refreshUserDefinedDistances];
}


- (void)dealloc {
    [distanceUnitControl release];
    [userDefinedDistance1 release];
    [userDefinedDistance2 release];
    [userDefinedDistance3 release];
    [userDefinedDistance4 release];
    [super dealloc];
}
@end

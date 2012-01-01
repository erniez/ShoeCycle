//
//  AddDistanceViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddDistanceViewController.h"
#import "StandardDistancesViewController.h"

@implementation AddDistanceViewController
@synthesize runDateField;
@synthesize enterDistanceField;
@synthesize totalDistanceField;
@synthesize pickerView, doneButton,runDateFormatter, standardDistanceString;


- (id)init
{
    // Call the class designated initializer
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        // Get tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        [tbi setTitle:@"Add Distance"];
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
    NSLog(@"standardDistanceString = %@", standardDistanceString);
    if (standardDistanceString != nil) {
        [enterDistanceField setText:standardDistanceString];
    }

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
    
    enterDistanceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        enterDistanceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    NSLog(@"View Did Load addDistanceViewController");
    
    [totalDistanceField setText:[NSString stringWithFormat:@"%.1f",0.0]];
    self.runDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.runDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.runDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    runDateField.delegate = self;
//    NSLog(@"%@",[self.runDateFormatter stringFromDate:[NSDate date]]);
    [runDateField setText:[NSString stringWithFormat:[self.runDateFormatter stringFromDate:[NSDate date]]]];

//    [self setTotalDistanceField:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    standardDistanceString = nil;
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
    [self setTotalDistanceField:nil];
    [runDateField release];
    [runDateField release];
    [self setRunDateField:nil];
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
    [totalDistanceField release];
    [runDateField release];
    [runDateField release];
    [runDateField release];
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
    float addDistance, total;
    
    // clear any editors that may be visible (clicking directly from distance number pad)
    [[self view] endEditing:YES];
    
    total = [[totalDistanceField text] floatValue]; 
    addDistance = [[enterDistanceField text] floatValue];
    total += addDistance;    
    
    [totalDistanceField setText:[NSString stringWithFormat:@"%.1f",total]];
    
    enterDistanceField.text = nil;
    [runDateField setText:[NSString stringWithFormat:[self.runDateFormatter stringFromDate:[NSDate date]]]];
    
    NSLog(@"%.1f",total);
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
    StandardDistancesViewController *modalViewController = [[StandardDistancesViewController alloc] initWithDistance:self];
    
    [self presentModalViewController:modalViewController animated:YES];
    
}


- (void)actionSheetCancel:(id)sender
{
    NSLog(@"actionSHeetCancel");
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"%@",[self.runDateFormatter stringFromDate:self.pickerView.date]);
    [runDateField setText:[NSString stringWithFormat:[self.runDateFormatter stringFromDate:self.pickerView.date]]];

    
}

@end

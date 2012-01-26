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

extern NSInteger distanceUnit;
float const milesToKilometers;

@implementation AddDistanceViewController
@synthesize nameField;
@synthesize runDateField;
@synthesize maxDistanceLabel;
@synthesize enterDistanceField;
@synthesize totalDistanceField;
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
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        [tbi setTitle:@"Add Distance"];
        
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
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert autorelease];
    [alert show];
    return;
    }
    
    self.distShoe = [shoes objectAtIndex:0];
    NSMutableArray *runs = [[NSMutableArray alloc] initWithArray:[distShoe.history allObjects]];
    float runTotal = 0;
    int i = 0;
    do {
        History *tempHist = [runs objectAtIndex:i];
        runTotal = runTotal +  [tempHist.runDistance floatValue];
        NSLog (@"runDistance = %.2f",[tempHist.runDistance floatValue]);
        i++;
    } while (i < [distShoe.history count]);
    NSLog(@"run total = %.2f",runTotal);
    
    nameField.text = [NSString stringWithFormat:@"%@: %@",distShoe.brand, distShoe.desc];
    totalDistanceProgress.progress = distShoe.totalDistance.floatValue/distShoe.maxDistance.floatValue;
    [maxDistanceLabel setText:[NSString stringWithFormat:@"Max: %.0f",[distShoe.maxDistance floatValue]]];
    [imageView setImage:[distShoe thumbnail]];
    
//    [totalDistanceField setText:[UserDistanceSetting displayDistance:[distShoe.totalDistance floatValue]]];
    [totalDistanceField setText:[UserDistanceSetting displayDistance:runTotal]];
    
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
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    if ([shoes count]) {
        distShoe = [shoes objectAtIndex:0];
    }
    
    nameField.text = distShoe.brand;
/*    float displayValue = [distShoe.totalDistance floatValue];
    if ([UserDistanceSetting getDistanceUnit]) {
        displayValue = displayValue * milesToKilometers;
    } */
    
    [totalDistanceField setText:[UserDistanceSetting displayDistance:[distShoe.totalDistance floatValue]]];
      
    NSLog(@"View Did Load addDistanceViewController");
    
//    [totalDistanceField setText:[NSString stringWithFormat:@"%.1f",shoe.totalDistance]];
    self.runDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.runDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.runDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    runDateField.delegate = self;
//    NSLog(@"%@",[self.runDateFormatter stringFromDate:[NSDate date]]);
    self.addRunDate = [NSDate date];
     NSLog(@"run date = %@",addRunDate);
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];

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
    [self setTotalDistanceField:nil];
    [runDateField release];
    [runDateField release];
    [self setRunDateField:nil];
    [self setNameField:nil];
    [self setTotalDistanceProgress:nil];
    [self setMaxDistanceLabel:nil];
    [imageView release];
    imageView = nil;
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
    [distShoe release];
    [nameField release];
    [totalDistanceProgress release];
    [maxDistanceLabel release];
    [imageView release];
    [addRunDate release];
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
    NSDate *testDate;
    
    // clear any editors that may be visible (clicking directly from distance number pad)
    [[self view] endEditing:YES];
    

    addDistance = [UserDistanceSetting enterDistance:[enterDistanceField text]]; 
    if (standardDistance) {
        addDistance = standardDistance;
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
    
    distShoe.totalDistance = [NSNumber numberWithFloat:(addDistance + [distShoe.totalDistance floatValue])];
    
    NSLog(@"totalDistance = %@",distShoe.totalDistance);
    
    /*    float displayValue = [distShoe.totalDistance floatValue];
     if ([UserDistanceSetting getDistanceUnit]) {
     displayValue = displayValue * milesToKilometers;
     } */
    
    [totalDistanceField setText:[UserDistanceSetting displayDistance:[distShoe.totalDistance floatValue]]];
    
//    [totalDistanceField setText:[NSString stringWithFormat:@"%.2f",[distShoe.totalDistance floatValue]]];
    
    enterDistanceField.text = nil;
    standardDistance = 0;
    [runDateField setText:[self.runDateFormatter stringFromDate:[NSDate date]]];
    totalDistanceProgress.progress = distShoe.totalDistance.floatValue/distShoe.maxDistance.floatValue;
    
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

@end

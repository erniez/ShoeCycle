//
//  StandardDistancesViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StandardDistancesViewController.h"
#import "AddDistanceViewController.h"
#import "UserDistanceSetting.h"


// Standard Distance Constants
const float k5kInMiles = 3.10685596;
const float k10kInMiles = 6.21371192;
const float kHalfMarathon = 13.109375;
const float kMarathon = 26.21875;
const float k5Miles = 5;
const float k10Miles = 10;
// end Standard Distance Constants


@implementation StandardDistancesViewController

@synthesize distanceString;
@synthesize addDistanceViewController;
@synthesize userDefinedDistance1Button;
@synthesize userDefinedDistance2Button;
@synthesize userDefinedDistance3Button;
@synthesize userDefinedDistance4Button;
@synthesize halfMarathonButton;

- (id)initWithDistance:(AddDistanceViewController *)vc
{
//    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // initialize with the AddDistanceViewController being passed in.
        self.addDistanceViewController = vc;                    
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
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
    if([UserDistanceSetting getUserDefinedDistance1])
    {
        [userDefinedDistance1Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]] 
                                    forState:UIControlStateNormal];
    }
   
    if([UserDistanceSetting getUserDefinedDistance2])
    {
        [userDefinedDistance2Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]] 
                                    forState:UIControlStateNormal];
    }

    if([UserDistanceSetting getUserDefinedDistance3])
    {
        [userDefinedDistance3Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]] 
                                    forState:UIControlStateNormal];
    }

    if([UserDistanceSetting getUserDefinedDistance4])
    {
        [userDefinedDistance4Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]] 
                                    forState:UIControlStateNormal];
    }

    halfMarathonButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)viewDidUnload
{
    NSLog(@"Standard Distance viewDidUnload");
    [self setUserDefinedDistance1Button:nil];
    [self setUserDefinedDistance2Button:nil];
    [self setUserDefinedDistance3Button:nil];
    [self setUserDefinedDistance4Button:nil];
    [self setHalfMarathonButton:nil];
    [self setAddDistanceViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction) distance5kButtonPressed:(id)sender
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k5kInMiles]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distance10kButtonPressed:(id)sender
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k10kInMiles]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distance5MilesButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k5Miles]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distanceTenMilesButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k10Miles]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distanceHalfMarathonButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:kHalfMarathon]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distanceMarathonButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:kMarathon]];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)userDefinedDistance1ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)userDefinedDistance2ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]]];    
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)userDefinedDistance3ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]]];    
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)userDefinedDistance4ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]]];    
    [self dismissModalViewControllerAnimated:YES];
}


@end

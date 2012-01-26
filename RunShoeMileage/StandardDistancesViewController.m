//
//  StandardDistancesViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StandardDistancesViewController.h"
#import "AddDistanceViewController.h"


@implementation StandardDistancesViewController

@synthesize distanceString;
@synthesize addDistanceViewController;

- (id)initWithDistance:(AddDistanceViewController *)vc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
//        vc.standardDistanceString = @"test init";
//        self.distanceString = vc.standardDistanceString;
//        self.distanceString = @"test init";
        addDistanceViewController = vc;
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
        [cancelItem release];

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
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
    
    addDistanceViewController->standardDistance = 3.10685596;
    
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distance10kButtonPressed:(id)sender
{
    addDistanceViewController->standardDistance = 6.21371192;

    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)distance5MilesButtonPressed:(id)sender 
{
    addDistanceViewController->standardDistance = 5.0;
    
    [self dismissModalViewControllerAnimated:YES];

}


- (IBAction)distanceTenMilesButtonPressed:(id)sender 
{
    addDistanceViewController->standardDistance = 10.0;
    
    [self dismissModalViewControllerAnimated:YES];

}


- (IBAction)distanceHalfMarathonButtonPressed:(id)sender 
{
    addDistanceViewController->standardDistance = 13.109375;
    
    [self dismissModalViewControllerAnimated:YES];

}


- (IBAction)distanceMarathonButtonPressed:(id)sender 
{
    addDistanceViewController->standardDistance = 26.21875;
    
    [self dismissModalViewControllerAnimated:YES];

}


- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

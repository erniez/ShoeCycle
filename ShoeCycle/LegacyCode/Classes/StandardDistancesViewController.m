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
#import "UIColor+ShoeCycleColors.h"
#import "UIUtilities.h"
#import "AnalyticsLogger_Legacy.h"


// Standard Distance Constants
const float k5kInMiles = 3.10685596;
const float k10kInMiles = 6.21371192;
const float kHalfMarathon = 13.109375;
const float kMarathon = 26.21875;
const float k5Miles = 5;
const float k10Miles = 10;
// end Standard Distance Constants


@interface StandardDistancesViewController ()

@property (weak, nonatomic) IBOutlet UIView *popularDistancesBackground;
@property (weak, nonatomic) IBOutlet UIView *favoriteDistancesBackground;
@property (weak, nonatomic) IBOutlet UILabel *popDistancesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDstancesTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stepsImageView;

@end

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
    self = [super initWithNibName:nil bundle:nil];
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
    
    UIImage *templateImage = [[UIImage imageNamed:@"steps"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.stepsImageView.image = templateImage;
    self.stepsImageView.tintColor = [UIColor shoeCycleBlue];
    
    
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    self.popDistancesTitleLabel.textColor = [UIColor shoeCycleBlue];
    self.favDstancesTitleLabel.textColor = [UIColor shoeCycleGreen];
    
    self.popularDistancesBackground.layer.borderColor = [UIColor shoeCycleBlue].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.popularDistancesBackground];
    
    self.favoriteDistancesBackground.layer.borderColor = [UIColor shoeCycleGreen].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.favoriteDistancesBackground];
    
    // Create dotted lines
    CGRect lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.popularDistancesBackground.bounds.size.height);
    UIView *lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleBlue]];
    [self.popularDistancesBackground addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.favoriteDistancesBackground.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleGreen]];
    [self.favoriteDistancesBackground addSubview:lineView];
    
    NSInteger analytics_FavoritesCount = 0;
    
    if([UserDistanceSetting getUserDefinedDistance1])
    {
        [userDefinedDistance1Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]] 
                                    forState:UIControlStateNormal];
        analytics_FavoritesCount++;
    }
   
    if([UserDistanceSetting getUserDefinedDistance2])
    {
        [userDefinedDistance2Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]] 
                                    forState:UIControlStateNormal];
        analytics_FavoritesCount++;
    }

    if([UserDistanceSetting getUserDefinedDistance3])
    {
        [userDefinedDistance3Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]] 
                                    forState:UIControlStateNormal];
        analytics_FavoritesCount++;
    }

    if([UserDistanceSetting getUserDefinedDistance4])
    {
        [userDefinedDistance4Button setTitle:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]] 
                                    forState:UIControlStateNormal];
        analytics_FavoritesCount++;
    }

    halfMarathonButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [[AnalyticsLogger_Legacy sharedLogger] logEventWithName:kShowFavoriteDistancesEvent userInfo:@{kNumberOfFavoritesUsedKey : @(analytics_FavoritesCount)}];
}

- (void)viewDidUnload
{
    EZLog(@"Standard Distance viewDidUnload");
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
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)distance10kButtonPressed:(id)sender
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k10kInMiles]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)distance5MilesButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k5Miles]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)distanceTenMilesButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:k10Miles]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)distanceHalfMarathonButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:kHalfMarathon]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)distanceMarathonButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:kMarathon]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)userDefinedDistance1ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance1]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)userDefinedDistance2ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance2]]];    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)userDefinedDistance3ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance3]]];    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)userDefinedDistance4ButtonPressed:(id)sender 
{
    [addDistanceViewController.enterDistanceField setText:[UserDistanceSetting displayDistance:[UserDistanceSetting getUserDefinedDistance4]]];    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

//
//  StandardDistancesViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddDistanceViewController;

@interface StandardDistancesViewController : UIViewController
{
    NSString *distanceString;
    AddDistanceViewController *addDistanceViewController;

}

@property (nonatomic, strong) NSString *distanceString;
@property (nonatomic, strong) AddDistanceViewController *addDistanceViewController;
@property (strong, nonatomic) IBOutlet UIButton *userDefinedDistance1Button;
@property (strong, nonatomic) IBOutlet UIButton *userDefinedDistance2Button;
@property (strong, nonatomic) IBOutlet UIButton *userDefinedDistance3Button;
@property (strong, nonatomic) IBOutlet UIButton *userDefinedDistance4Button;
@property (strong, nonatomic) IBOutlet UIButton *halfMarathonButton;

- (id)initWithDistance:(AddDistanceViewController *)vc;

- (IBAction) distance5kButtonPressed:(id)sender;
- (IBAction)distance10kButtonPressed:(id)sender;
- (IBAction)distance5MilesButtonPressed:(id)sender;
- (IBAction)distanceTenMilesButtonPressed:(id)sender;
- (IBAction)distanceHalfMarathonButtonPressed:(id)sender;
- (IBAction)distanceMarathonButtonPressed:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)userDefinedDistance1ButtonPressed:(id)sender;
- (IBAction)userDefinedDistance2ButtonPressed:(id)sender;
- (IBAction)userDefinedDistance3ButtonPressed:(id)sender;
- (IBAction)userDefinedDistance4ButtonPressed:(id)sender;

@end

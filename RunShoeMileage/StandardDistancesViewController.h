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

@property (nonatomic, retain) NSString *distanceString;
@property (nonatomic, retain) AddDistanceViewController *addDistanceViewController;

- (id)initWithDistance:(AddDistanceViewController *)vc;

- (IBAction) distance5kButtonPressed:(id)sender;
- (IBAction)distance10kButtonPressed:(id)sender;
- (IBAction)distance5MilesButtonPressed:(id)sender;
- (IBAction)distanceTenMilesButtonPressed:(id)sender;
- (IBAction)distanceHalfMarathonButtonPressed:(id)sender;
- (IBAction)distanceMarathonButtonPressed:(id)sender;
- (IBAction)cancel:(id)sender;

@end

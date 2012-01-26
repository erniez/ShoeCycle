//
//  SetupViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetupViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISegmentedControl *distanceUnitControl;

- (IBAction)changeDistanceUnits:(id)sender;
@end

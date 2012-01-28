//
//  SetupViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetupViewController : UIViewController
<UITextFieldDelegate>
{

}

@property (retain, nonatomic) IBOutlet UISegmentedControl *distanceUnitControl;
@property (retain, nonatomic) IBOutlet UITextField *userDefinedDistance1;
@property (retain, nonatomic) IBOutlet UITextField *userDefinedDistance2;
@property (retain, nonatomic) IBOutlet UITextField *userDefinedDistance3;
@property (retain, nonatomic) IBOutlet UITextField *userDefinedDistance4;

- (IBAction)changeDistanceUnits:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)refreshUserDefinedDistances;

@end

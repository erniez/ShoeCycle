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

- (IBAction)changeDistanceUnits:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)refreshUserDefinedDistances;
- (IBAction)aboutButton:(id)sender;

@end

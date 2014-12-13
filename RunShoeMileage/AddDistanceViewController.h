//
//  AddDistanceViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoe.h"
@class History;

@interface AddDistanceViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *enterDistanceField;

- (void)calculateDaysLeftProgressBar;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addDistanceButton:(id)sender;
- (IBAction)standardDistancesButtonPressed:(id)sender;
- (IBAction)runHistoryButtonPressed:(id)sender;

@end

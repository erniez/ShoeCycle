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

@interface AddDistanceViewController : UIViewController
<UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *maxDistanceLabel;
@property (nonatomic, weak) IBOutlet UITextField *enterDistanceField;
@property (nonatomic, weak) IBOutlet UILabel *totalDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceUnitLabel;
@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, weak) IBOutlet UITextField *runDateField;
@property (nonatomic, strong) NSDateFormatter *runDateFormatter; 
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, strong) Shoe *distShoe;
@property (nonatomic, strong) History *hist;
@property (nonatomic, weak) IBOutlet UIProgressView *totalDistanceProgress;
@property (nonatomic, strong) NSDate *addRunDate;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *expirationDateLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel*daysLeftIdentificationLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *wearProgress;
@property (nonatomic, strong) UIAlertController *actionSheet;

- (void)calculateDaysLeftProgressBar;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addDistanceButton:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction)standardDistancesButtonPressed:(id)sender;
- (IBAction)runHistoryButtonPressed:(id)sender;

@end

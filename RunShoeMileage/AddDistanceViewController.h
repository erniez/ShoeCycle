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
{    
    UITextField *enterDistanceField;
 //   UITextField *totalDistanceLabel;
    
    UIDatePicker *pickerView;
    
    UITextField *runDateField;
    NSDate *addRunDate;
    NSDateFormatter *runDateFormatter;
    UITextField *nameField;
    
    UIActionSheet *actionSheet;
    
    Shoe *distShoe;
    History *hist;
    UIProgressView *totalDistanceProgress;
    
    UILabel *maxDistanceLabel;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic, strong) IBOutlet UILabel *maxDistanceLabel;
@property (nonatomic, strong) IBOutlet UITextField *enterDistanceField;
@property (nonatomic, strong) IBOutlet UILabel *totalDistanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceUnitLabel;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView; 
@property (nonatomic, strong) IBOutlet UITextField *runDateField;
@property (nonatomic, strong) NSDateFormatter *runDateFormatter; 
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) Shoe *distShoe;
@property (nonatomic, strong) History *hist;
@property (nonatomic, strong) IBOutlet UIProgressView *totalDistanceProgress;
@property (nonatomic, strong) NSDate *addRunDate;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (strong, nonatomic) IBOutlet UILabel*daysLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel*daysLeftIdentificationLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *wearProgress;


- (void)actionSheetCancelEZ:(id)sender;
- (void)calculateDaysLeftProgressBar;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addDistanceButton:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction)standardDistancesButtonPressed:(id)sender;
- (IBAction)runHistoryButtonPressed:(id)sender;

@end

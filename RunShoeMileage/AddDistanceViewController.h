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
	UIBarButtonItem *doneButton;	// this button appears only when the date picker is open
    
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
    
    @public
    float standardDistance;
}
@property (nonatomic, retain) IBOutlet UILabel *maxDistanceLabel;
@property (nonatomic, retain) IBOutlet UITextField *enterDistanceField;
@property (nonatomic, retain) IBOutlet UILabel *totalDistanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceUnitLabel;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView; 
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UITextField *runDateField;
@property (nonatomic, retain) NSDateFormatter *runDateFormatter; 
@property (nonatomic, retain) IBOutlet UITextField *nameField;
// @property (nonatomic, readwrite, retain) NSString *standardDistanceString; 
@property (nonatomic, retain) Shoe *distShoe;
@property (nonatomic, retain) History *hist;
@property (nonatomic, retain) IBOutlet UIProgressView *totalDistanceProgress;
@property (nonatomic, retain) NSDate *addRunDate;
@property (retain, nonatomic) IBOutlet UILabel *startDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (retain, nonatomic) IBOutlet UILabel*daysLeftLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *wearProgress;


- (void)actionSheetCancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addDistanceButton:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction)standardDistancesButtonPressed:(id)sender;
- (IBAction)runHistoryButtonPressed:(id)sender;

@end

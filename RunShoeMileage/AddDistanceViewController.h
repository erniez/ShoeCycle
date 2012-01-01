//
//  AddDistanceViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDistanceViewController : UIViewController
<UITextFieldDelegate, UIActionSheetDelegate>
{    
    UITextField *enterDistanceField;
    UITextField *totalDistanceField;
    
    UIDatePicker *pickerView;
	UIBarButtonItem *doneButton;	// this button appears only when the date picker is open
    
    UITextField *runDateField;
    NSDateFormatter *runDateFormatter;
    
    UIActionSheet *actionSheet;

    NSString *standardDistanceString;
    
}
@property (nonatomic, retain) IBOutlet UITextField *enterDistanceField;
@property (nonatomic, retain) IBOutlet UITextField *totalDistanceField;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView; 
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UITextField *runDateField;
@property (nonatomic, retain) NSDateFormatter *runDateFormatter; 
@property (nonatomic, readwrite, retain) NSString *standardDistanceString; 


- (void)actionSheetCancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addDistanceButton:(id)sender;
- (IBAction)callDP:(id)sender;
- (IBAction)standardDistancesButtonPressed:(id)sender;

@end

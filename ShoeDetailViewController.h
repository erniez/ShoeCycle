//
//  ShoeDetailViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoe.h"

@interface ShoeDetailViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
//    IBOutlet UITextField *brand;
    IBOutlet UITextField *name;
    IBOutlet UITextField *maxDistance;
    IBOutlet UITextField *expirationDateField;
    IBOutlet UITextField *startDistance;
    UITextField *brandField;
    IBOutlet UIImageView *imageView;
    NSString *testBrandString;
    NSString *testNameString;
    UIPopoverController *imagePickerPopover;
    UIDatePicker *expPickerView;
    NSDateFormatter *expirationDateFormatter;
    UIActionSheet *dateActionSheet;
    UIActionSheet *pictureActionSheet;
    NSDate *expirationDate;
    NSDate *startDate;
    NSDate *currentDate;
    UITextField *currentDateField;
    Shoe *shoe;
    UIToolbar *toolbar;
    id pictureButton;

}
@property (nonatomic, retain) IBOutlet UITextField *brandField;
@property (nonatomic, retain) NSString *testBrandString;
@property (nonatomic, retain) NSString *testNameString;
@property (nonatomic, retain) IBOutlet UIDatePicker *expPickerView;
@property (nonatomic, retain) NSDateFormatter *expirationDateFormatter; 
@property (nonatomic, retain) Shoe *shoe;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) UIToolbar	*toolbar;
@property (retain, nonatomic) IBOutlet UITextField *startDateField;
@property (retain, nonatomic) UITextField *currentDateField;
@property (retain, nonatomic) IBOutlet UITextField *maxDistance;

- (IBAction)takePicture:(id)sender;
- (id)initForNewItem:(BOOL)isNew;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)callDP:(id)sender;
- (BOOL)validation;

//- (void)changeDate:(id)sender;

@end

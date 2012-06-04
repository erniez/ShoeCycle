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
    IBOutlet UIImageView *imageView;
    UITextField *brandField;
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
@property (nonatomic, strong) IBOutlet UITextField *brandField;
@property (nonatomic, strong) IBOutlet UIDatePicker *expPickerView;
@property (nonatomic, strong) NSDateFormatter *expirationDateFormatter; 
@property (nonatomic, strong) Shoe *shoe;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) UIToolbar	*toolbar;
@property (strong, nonatomic) IBOutlet UITextField *startDateField;
@property (strong, nonatomic) UITextField *currentDateField;
@property (strong, nonatomic) IBOutlet UITextField *maxDistance;
@property (strong, nonatomic) IBOutlet UITextField *expirationDateField;

- (IBAction)takePicture:(id)sender;
- (id)initForNewItem:(BOOL)isNew;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)callDP:(id)sender;

//- (void)changeDate:(id)sender;

@end

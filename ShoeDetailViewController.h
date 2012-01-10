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
    UIActionSheet *actionSheet;
    NSDate *expirationDate;
    Shoe *shoe;
    UIToolbar *toolbar;

}
@property (nonatomic, retain) IBOutlet UITextField *brandField;
@property (nonatomic, retain) NSString *testBrandString;
@property (nonatomic, retain) NSString *testNameString;
@property (nonatomic, retain) IBOutlet UIDatePicker *expPickerView;
@property (nonatomic, retain) NSDateFormatter *expirationDateFormatter; 
@property (nonatomic, retain) Shoe *shoe;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) UIToolbar	*toolbar;

- (IBAction)takePicture:(id)sender;
- (id)initForNewItem:(BOOL)isNew;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)callDP:(id)sender;
//- (void)changeDate:(id)sender;

@end

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
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *brandField;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIDatePicker *expPickerView;
@property (nonatomic, weak) IBOutlet UITextField *startDistance;
@property (nonatomic, strong) NSDateFormatter *expirationDateFormatter;
@property (nonatomic, strong) Shoe *shoe;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) UIToolbar	*toolbar;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (strong, nonatomic) UITextField *currentDateField;
@property (weak, nonatomic) IBOutlet UITextField *maxDistance;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateField;
@property (nonatomic, strong) NSString *testBrandString;
@property (nonatomic, strong) NSString *testNameString;

- (IBAction)takePicture:(id)sender;
- (id)initForNewItem:(BOOL)isNew;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)callDP:(id)sender;

@end

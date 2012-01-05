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
{
//    IBOutlet UITextField *brand;
    IBOutlet UITextField *name;
    IBOutlet UITextField *maxDistance;
    IBOutlet UITextField *expirationDate;
    IBOutlet UITextField *startDistance;
    UITextField *brandField;
    IBOutlet UIImageView *imageView;
    NSString *testBrandString;
    NSString *testNameString;
    UIPopoverController *imagePickerPopover;
    Shoe *shoe;
}
@property (nonatomic, retain) IBOutlet UITextField *brandField;
@property (nonatomic, retain) NSString *testBrandString;
@property (nonatomic, retain) NSString *testNameString;
@property (nonatomic, retain) Shoe *shoe;

- (IBAction)takePicture:(id)sender;
- (id)initForNewItem:(BOOL)isNew;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end

//
//  ShoeDetailViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShoeDetailViewController.h"
#import "ShoeStore.h"
#import "ImageStore.h"
#import "UserDistanceSetting.h"

@implementation ShoeDetailViewController

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"ShoeDetailViewController" bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                         target:self 
                                         action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                           target:self
                                           action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
            UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:@selector(takePicture:)];
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
            
            NSArray *items = [NSArray arrayWithObjects:camera, spacer, nil];
            
            self.toolbar = [UIToolbar new];
            self.toolbar.barStyle = UIBarStyleDefault;
            
            // size up the toolbar and set its frame
            [self.toolbar sizeToFit];
            CGFloat toolbarHeight = [self.toolbar bounds].size.height;
            CGFloat navBarHeight = 44;
            CGFloat statusBarHeight = 20;
            CGRect mainViewBounds = self.view.bounds;
            [self.toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
                                         CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight) - navBarHeight - statusBarHeight,
                                         CGRectGetWidth(mainViewBounds),
                                         toolbarHeight)];
            
            [self.toolbar setItems:items animated:YES];
            
            [self.view addSubview:self.toolbar];
            
            self.maxDistance.text = @"350";
        }
    }
    
    return self;
}

/*
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem:"
                                 userInfo:nil];
    return nil;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    EZLog(@"entered shoeDetail didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    EZLog(@"leaving shoeDetail didReceiveMemoryWarning");    
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.brandField setText:self.shoe.brand];
    
    [self.maxDistance setText:[UserDistanceSetting displayDistance:[self.shoe.maxDistance floatValue]]];
    [self.startDistance setText:[UserDistanceSetting displayDistance:[self.shoe.startDistance floatValue]]];

    self.expirationDateFormatter = [[NSDateFormatter alloc] init];
	[self.expirationDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.expirationDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.expirationDate = self.shoe.expirationDate;
    [self.expirationDateField setText:[self.expirationDateFormatter stringFromDate:self.shoe.expirationDate]];
    self.startDate = self.shoe.startDate;
    [self.startDateField setText:[self.expirationDateFormatter stringFromDate:self.shoe.startDate]];
    EZLog(@"Will Appear Date = %@",self.shoe.expirationDate);
    
    NSString *imageKey = [self.shoe imageKey];
    
    if (imageKey) {
        // Get image for image key from image store
        UIImage *imageToDisplay = [[ImageStore defaultImageStore] imageForKey:imageKey];
        
        // Use that image to put on the screen in imageView
        [self.imageView setImage:imageToDisplay];
    } else {
        // Clear the imageView
        [self.imageView setImage:nil];
    }

}


- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    self.shoe.brand = self.brandField.text;
    self.shoe.maxDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.maxDistance.text]];
    EZLog(@"Leaving maxDistance %@",self.shoe.maxDistance);
    self.shoe.startDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.startDistance.text]];
    self.shoe.expirationDate = self.expirationDate;
    self.shoe.startDate = self.startDate;
    EZLog(@"Will Disappear Start Date = %@",self.expPickerView.date);
    EZLog(@"Leaving Date = %@",self.shoe.expirationDate);
    EZLog(@"************** Leaving Detail View ************");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.maxDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    self.startDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.startDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
 

    // Do any additional setup after loading the view from its nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/* ==============================================================
 End View Lifecycle
 =============================================================== */

// ==========================================================================================
// dismiss keyboards
// ==========================================================================================

- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// ==========================================================================================
// end dismiss keyboards
// ==========================================================================================


- (IBAction)takePicture:(id)sender
{
    self.pictureActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Picture Method"
                                              delegate:self 
                                     cancelButtonTitle:@"Cancel" 
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Camera", @"Library", nil];
    
    [self.pictureActionSheet setActionSheetStyle:UIActionSheetStyleDefault];

    [self.pictureActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [self.pictureActionSheet setDelegate:self];
    
    pictureButton = sender;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.pictureActionSheet) {
        
        [self.pictureActionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
         
        switch (buttonIndex) {
            case 0 :
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                break;
            case 1 :
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
            default:
                return;
        }
         // If our device has a camera, we want to take a picture, otherwise we just pick from photo library
         [imagePicker setDelegate:self];
         
         // Place image picker on the screen
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         // Create a new popover controller that will display the imagePicker
         UIPopoverController *imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
         
         [imagePickerPopover setDelegate:self];
         
         // Display the popover controller, sender is the camera bar button item
         [imagePickerPopover presentPopoverFromBarButtonItem:pictureButton
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
         }
         else
         {
             // Place image picker on the screen
             [self presentViewController:imagePicker animated:YES completion:nil];
         }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *oldKey = [self.shoe imageKey];
    
    
    // Did the possession already have an image?
    if (oldKey) {
        // Delete the old image
        [[ImageStore defaultImageStore] deleteImageForKey:oldKey];
    }
    
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // Create a CFUUID object - it knows how to create unique identifier strings
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    
    // Create a string from a unique identifier
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    // Use that unique ID to set our possessions imageKey
    [self.shoe setImageKey:(__bridge NSString *)newUniqueIDString];
    
    // We used "Create" in the functions to make objects, we need to release them
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // Store  image in the ImageStore with this key
    [[ImageStore defaultImageStore] setImage:image withWidth:210 withHeight:140 forKey:[self.shoe imageKey]];

    // Put that image onto the screen in our image view
    [self.imageView setImage:image];
    
    [self.shoe setThumbnailDataFromImage:image width:143 height:96];
    
    // Take image picker off the screen - You must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender
{
    self.shoe.brand = self.brandField.text;
            
    EZLog(@"%@", self.shoe.brand);
    
    // This message gets forwarded to the parentViewController  
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)])
//        [delegate itemDetailViewControllerWillDismiss:self];
}


- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the Possession from the store
    // This message gets forwarded to the parentViewController

    [[ShoeStore defaultStore] removeShoe:self.shoe];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)])
 //       [delegate itemDetailViewControllerWillDismiss:self];
}


- (IBAction)callDP:(id)sender 
{
    
    [[self view] endEditing:YES];           // clear any editors that may be visible (clicking from distance to date)
    
    EZLog(@"callDP sender = %@", sender);
    self.currentDateField = sender;
    
    self.dateActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.dateActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    self.expPickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    self.expPickerView.tag = 10;
    self.expPickerView.datePickerMode = UIDatePickerModeDate;
    self.expPickerView.date = self.currentDate;
    
    [self.dateActionSheet addSubview:self.expPickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancelEZ:) forControlEvents:UIControlEventValueChanged];
    [self.dateActionSheet addSubview:closeButton];
    
    [self.dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [self.dateActionSheet setBounds:CGRectMake(0, 0, 320, 485)];

    EZLog(@"leaving CallDP");
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.expirationDateField) {
        self.currentDate = self.expirationDate;
        [self callDP:self.expirationDateField];
        return NO;
    }
    
    if (textField == self.startDateField) {
        self.currentDate = self.startDate;
        [self callDP:self.startDateField];
        return NO;
    }
    
    return YES;    
}


- (void)actionSheetCancelEZ:(id)sender
{
    if (self.currentDateField == self.startDateField){
            self.startDate = self.expPickerView.date;
        }
    
    if (self.currentDateField == self.expirationDateField) {
            self.expirationDate = self.expPickerView.date;
        }
    
    EZLog(@"actionSheetCancel - Current Date = %@",self.currentDate);
    EZLog(@"Start Date = %@",self.startDate);
    [self.currentDateField setText:[self.expirationDateFormatter stringFromDate:self.expPickerView.date]];
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


@end

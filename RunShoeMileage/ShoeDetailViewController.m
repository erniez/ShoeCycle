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
#import "UIColor+ShoeCycleColors.h"
#import "UIUtilities.h"
#import "RunDatePickerViewController.h"


@interface ShoeDetailViewController () <RunDatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIView *shoeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *distanceBackroundView;
@property (weak, nonatomic) IBOutlet UIView *wearBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *shoeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wearTimeTitleLabel;
@property (nonatomic, strong) RunDatePickerViewController *runDatePickerViewController;

@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL newShoeIsCancelled;

@end

@implementation ShoeDetailViewController

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"ShoeDetailViewController" bundle:nil];
    
    if (self) {
        if (isNew) {
            _isNew = isNew;
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
            
            self.maxDistance.text = @"350";
        }
    }
    
    return self;
}

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
    
    if (self.isNew)
    {
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:@selector(takePicture:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
        
        NSArray *items = [NSArray arrayWithObjects:camera, spacer, nil];
        
        self.toolbar = [UIToolbar new];
        self.toolbar.barStyle = UIBarStyleDefault;
        
        // size up the toolbar and set its frame
        [self.toolbar sizeToFit];
        CGFloat toolbarHeight = [self.toolbar bounds].size.height;
        self.toolbar.frame = CGRectMake(0, self.view.bounds.size.height - toolbarHeight, self.view.bounds.size.height, toolbarHeight);
        
        [self.toolbar setItems:items animated:YES];
        
        [self.view addSubview:self.toolbar];
    }


}


- (void)viewWillDisappear:(BOOL)animated
{

    if (!self.newShoeIsCancelled)
    {
        [super viewWillDisappear:animated];
        self.shoe.brand = self.brandField.text;
        self.shoe.maxDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.maxDistance.text]];
        EZLog(@"Leaving maxDistance %@",self.shoe.maxDistance);
        self.shoe.startDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:self.startDistance.text]];
        self.shoe.expirationDate = self.expirationDate;
        self.shoe.startDate = self.startDate;
        
        // Save changes, if any, unless cancelled (new shoe only)
        [[ShoeStore defaultStore] saveChangesEZ];
    }

    EZLog(@"Will Disappear Start Date = %@",self.expPickerView.date);
    EZLog(@"Leaving Date = %@",self.shoe.expirationDate);
    EZLog(@"************** Leaving Detail View ************");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    if ([UIUtilities isIphone4ScreenSize])
    {
        self.topSpaceConstraint.constant = 67.0;
        [self.view removeConstraint:self.verticalCenterConstraint];
    }
    else
    {
        [self.view removeConstraint:self.topSpaceConstraint];
    }
    
    self.maxDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.maxDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    self.startDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.startDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    self.shoeTitleLabel.textColor = [UIColor shoeCycleOrange];
    self.distanceTitleLabel.textColor = [UIColor shoeCycleGreen];
    self.wearTimeTitleLabel.textColor = [UIColor shoeCycleBlue];
    
    self.shoeBackgroundView.layer.borderColor = [UIColor shoeCycleOrange].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.shoeBackgroundView];
    
    self.distanceBackroundView.layer.borderColor = [UIColor shoeCycleGreen].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.distanceBackroundView];
    
    self.wearBackgroundView.layer.borderColor = [UIColor shoeCycleBlue].CGColor;
    [UIUtilities configureInputFieldBackgroundViews:self.wearBackgroundView];
    
    // Create dotted lines
    CGRect lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.shoeBackgroundView.bounds.size.height);
    UIView *lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleOrange]];
    [self.shoeBackgroundView addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.distanceBackroundView.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleGreen]];
    [self.distanceBackroundView addSubview:lineView];
    
    lineFrame = CGRectMake(lineXposition, 0, lineWidth, self.wearBackgroundView.bounds.size.height);
    lineView = [UIUtilities getDottedLineForFrame:lineFrame color:[UIColor shoeCycleBlue]];
    [self.wearBackgroundView addSubview:lineView];
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
    
    [[ShoeStore defaultStore] saveChangesEZ];
    
    // This message gets forwarded to the parentViewController  
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the Possession from the store
    // This message gets forwarded to the parentViewController

    [[ShoeStore defaultStore] removeShoe:self.shoe];
    self.newShoeIsCancelled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)callDP:(id)sender
{
    [[self view] endEditing:YES];   // clear any editors that may be visible (clicking from distance to date)
    
    self.currentDateField = sender;
    
    if (!self.runDatePickerViewController)
    {
        self.runDatePickerViewController = [[RunDatePickerViewController alloc] init];
        CGRect dpFrame = self.runDatePickerViewController.view.frame;
        dpFrame.origin.y = self.view.bounds.size.height;
        dpFrame.size.height = 250;
        self.runDatePickerViewController.view.frame = dpFrame;
        
        [self addChildViewController:self.runDatePickerViewController];
        [self.view addSubview:self.runDatePickerViewController.view];
        [self.runDatePickerViewController didMoveToParentViewController:self];
        
        self.runDatePickerViewController.delegate = self;
        
        dpFrame.origin.y -= self.runDatePickerViewController.view.bounds.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            self.runDatePickerViewController.view.frame = dpFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    [self.runDatePickerViewController setDate:self.currentDate];
}

#pragma mark - RunDatePickerViewControllerDelegate

- (void)dismissDatePicker:(RunDatePickerViewController *)datePicker
{
    [self willMoveToParentViewController:nil];
    CGRect dpFrame = datePicker.view.frame;
    dpFrame.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        datePicker.view.frame = dpFrame;
    } completion:^(BOOL finished) {
        [datePicker.view removeFromSuperview];
        [datePicker removeFromParentViewController];
        self.runDatePickerViewController = nil;
    }];
}

- (void)runDatePickerValueDidChange:(NSDate *)newDate
{
    if (self.currentDateField == self.startDateField){
        self.startDate = newDate;
    }
    
    if (self.currentDateField == self.expirationDateField) {
        self.expirationDate = newDate;
    }
    [self.currentDateField setText:[self.expirationDateFormatter stringFromDate:newDate]];
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

@end

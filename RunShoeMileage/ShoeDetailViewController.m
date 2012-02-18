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
@synthesize brandField, testBrandString, testNameString, shoe;
@synthesize expPickerView, expirationDateFormatter, expirationDate, startDate, currentDate;
@synthesize maxDistance;
@synthesize toolbar;
@synthesize startDateField, currentDateField;

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
            [doneItem release];
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                           target:self
                                           action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
            [cancelItem release];
            UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:@selector(takePicture:)];
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
            
            NSArray *items = [NSArray arrayWithObjects:camera, spacer, nil];
            
            toolbar = [UIToolbar new];
            toolbar.barStyle = UIBarStyleDefault;
            
            // size up the toolbar and set its frame
            [toolbar sizeToFit];
            CGFloat toolbarHeight = [toolbar frame].size.height;
            CGRect mainViewBounds = self.view.bounds;
            [toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
                                         CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
                                         CGRectGetWidth(mainViewBounds),
                                         toolbarHeight)];
            
            [toolbar setItems:items animated:YES];
            
            [self.view addSubview:toolbar];
            
            self.maxDistance.text = @"350";
            
                        
            [camera release];
            [spacer release];
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
        [rightButton release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [brandField setText:shoe.brand];
    [name setText:shoe.desc];
//    [maxDistance setText:[NSString stringWithFormat:@"%@",shoe.maxDistance]];
    [maxDistance setText:[UserDistanceSetting displayDistance:[shoe.maxDistance floatValue]]];
//    [startDistance setText:[NSString stringWithFormat:@"%@",shoe.startDistance]];
    [startDistance setText:[UserDistanceSetting displayDistance:[shoe.startDistance floatValue]]];
    
    self.expirationDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.expirationDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.expirationDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    expirationDateField.delegate = self;
    self.expirationDate = shoe.expirationDate;
    [expirationDateField setText:[self.expirationDateFormatter stringFromDate:shoe.expirationDate]];
    self.startDate = shoe.startDate;
    [startDateField setText:[self.expirationDateFormatter stringFromDate:shoe.startDate]];
    NSLog(@"Will Appear Date = %@",shoe.expirationDate);
    
    NSString *imageKey = [shoe imageKey];
    
    if (imageKey) {
        // Get image for image key from image store
        UIImage *imageToDisplay = [[ImageStore defaultImageStore] imageForKey:imageKey];
        
        // Use that image to put on the screen in imageView
        [imageView setImage:imageToDisplay];
    } else {
        // Clear the imageView
        [imageView setImage:nil];
    }

   
//    [brand setText:brandField];
}


- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    shoe.brand = brandField.text;
    shoe.desc = name.text;
    shoe.maxDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:maxDistance.text]];
    NSLog(@"Leaving maxDistance %@",shoe.maxDistance);
    shoe.startDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:startDistance.text]];
    shoe.expirationDate = expirationDate;
    shoe.startDate = self.startDate;
        NSLog(@"Will Disappear Start Date = %@",self.expPickerView.date);
    NSLog(@"Leaving Date = %@",shoe.expirationDate);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        maxDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
    startDistance.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        startDistance.keyboardType = UIKeyboardTypeDecimalPad;
    }
 

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
//    [brand release];
//    brand = nil;
    [name release];
    name = nil;
    [maxDistance release];
    maxDistance = nil;
    [expirationDateField release];
    expirationDateField = nil;
    [startDistance release];
    startDistance = nil;
    [self setBrandField:nil];
    [imageView release];
    imageView = nil;
    [self setStartDateField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
//    [brand release];
    [name release];
    [maxDistance release];
    [expirationDateField release];
    [startDistance release];
    [brandField release];
    [imageView release];
    [toolbar release];
    [startDateField release];
    [super dealloc];
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
    pictureActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Picture Method"
                                              delegate:self 
                                     cancelButtonTitle:@"Cancel" 
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Camera", @"Library", nil];
    
    [pictureActionSheet setActionSheetStyle:UIActionSheetStyleDefault];

    [pictureActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [pictureActionSheet setDelegate:self];
    
    pictureButton = sender;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == pictureActionSheet) {
        NSLog(@"Picture Actionsheet Button = %i",buttonIndex);
        [pictureActionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
         
        switch (buttonIndex) {
            case 0 :
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                break;
            case 1 :
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
            default:
                [imagePicker release];
                return;
        }
         // If our device has a camera, we want to take a picture, otherwise we just pick from photo library
/*         if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
         [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
         } else {
         [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
         }
*/         
         [imagePicker setDelegate:self];
         
         // Place image picker on the screen
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         // Create a new popover controller that will display the imagePicker
         imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
         
         [imagePickerPopover setDelegate:self];
         
         // Display the popover controller, sender is the camera bar button item
         [imagePickerPopover presentPopoverFromBarButtonItem:pictureButton
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
         } else {
         // Place image picker on the screen
         [self presentModalViewController:imagePicker animated:YES];
         }
         
         
         // The image picker will be retained by ItemDetailViewController until it has been dismissed
         [imagePicker release];        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *oldKey = [shoe imageKey];
    
    
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
    [shoe setImageKey:(NSString *)newUniqueIDString];
    
    // We used "Create" in the functions to make objects, we need to release them
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // Store  image in the ImageStore with this key
    [[ImageStore defaultImageStore] setImage:image withWidth:210 withHeight:140 forKey:[shoe imageKey]];

    // Put that image onto the screen in our image view
    [imageView setImage:image];
    
    [shoe setThumbnailDataFromImage:image width:120 height:80];
    
    // Take image picker off the screen - You must call this dismiss method
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)save:(id)sender
{
    shoe.brand = brandField.text;
    shoe.desc = name.text;
/*    int flag = 0;
    NSComparisonResult result = [expirationDate compare:startDate];
    NSLog(@"start date = %@, end date = %@",startDate,expirationDate);
    NSLog(@"Mad it to the save data routine. Compare = %i", result);
    
    if (result == NSOrderedAscending) {
        UIAlertView *dateAlert = [[UIAlertView alloc] initWithTitle:@"Your End Date is earlier than you Start Date.  Please correct."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [dateAlert autorelease];
        flag = 1;
        [dateAlert show];
    }
    if (flag == 1) {
        return;
    } */
    
 //   if (![self validation]) {
 //       return;
 //   }
            
    NSLog(@"%@", shoe.brand);
    
    // This message gets forwarded to the parentViewController  
    [self dismissModalViewControllerAnimated:YES];
    
//    if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)])
//        [delegate itemDetailViewControllerWillDismiss:self];
}


- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the Possession from the store
    // This message gets forwarded to the parentViewController

    [[ShoeStore defaultStore] removeShoe:shoe];
    [self dismissModalViewControllerAnimated:YES];
    
//    if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)])
 //       [delegate itemDetailViewControllerWillDismiss:self];
}


- (IBAction)callDP:(id)sender 
{
    
    [[self view] endEditing:YES];           // clear any editors that may be visible (clicking from distance to date)
    
    NSLog(@"callDP sender = %@", sender);
    currentDateField = sender;
    
    dateActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [dateActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    expPickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    expPickerView.tag = 10;
    expPickerView.datePickerMode = UIDatePickerModeDate;
//    [expPickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [dateActionSheet addSubview:expPickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancel:) forControlEvents:UIControlEventValueChanged];
    [dateActionSheet addSubview:closeButton];
    [closeButton release];
    
    
    //[actionSheet showInView:self.view];
    [dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [dateActionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    NSLog(@"leaving CallDP");
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == expirationDateField) {
        self.currentDate = expirationDate;
        [self callDP:expirationDateField];
        NSLog(@"Writing Expiration Date to local variable = %@",expirationDate);
        return NO;
    }
    
    if (textField == startDateField) {
        self.currentDate = startDate;
        [self callDP:startDateField];
        NSLog(@"Writing Start Date to local variable = %@",startDate);
        return NO;
    }
    
    return YES;    
}


- (void)actionSheetCancel:(id)sender
{

//    self.currentDate = self.expPickerView.date;
//    if (sender==dateActionSheet) {
//        if (currentDate == startDate) {
    if (currentDateField == startDateField){
            self.startDate = self.expPickerView.date;
        }
    
//    if (currentDate == expirationDate) {
    if (currentDateField == expirationDateField) {
            self.expirationDate = self.expPickerView.date;
        }
    
        NSLog(@"actionSheetCancel - Current Date = %@",self.currentDate);
        NSLog(@"Start Date = %@",self.startDate);
//      [expirationDateField setText:[self.expirationDateFormatter stringFromDate:self.expPickerView.date]];
        [currentDateField setText:[self.expirationDateFormatter stringFromDate:self.expPickerView.date]];
        [dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
//    }
    
}


//=====================================================================
//  Textfield validations
//=====================================================================

- (BOOL)validation
{
    int flag = 0;
    NSComparisonResult result = [expirationDate compare:startDate];

    if (result == NSOrderedAscending) {
        UIAlertView *dateAlert = [[UIAlertView alloc] initWithTitle:@"Your End Date is earlier than you Start Date.  Please correct."
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [dateAlert autorelease];
        flag = 1;
        [dateAlert show];
    }
    if (flag == 1) {
        return FALSE;
    }
    return TRUE;
}
@end

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

@implementation ShoeDetailViewController
@synthesize brandField, testBrandString, testNameString, shoe;
@synthesize expPickerView, expirationDateFormatter, expirationDate;
@synthesize toolbar;

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
    [maxDistance setText:[NSString stringWithFormat:@"%@",shoe.maxDistance]];
    [startDistance setText:[NSString stringWithFormat:@"%@",shoe.startDistance]];
    
    self.expirationDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.expirationDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.expirationDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    expirationDateField.delegate = self;
    expirationDate = shoe.expirationDate;
    [expirationDateField setText:[self.expirationDateFormatter stringFromDate:shoe.expirationDate]];
    NSLog(@"Arriving Date = %@",shoe.expirationDate);
    
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
    shoe.maxDistance = [NSNumber numberWithFloat:[maxDistance.text floatValue]];
    NSLog(@"Leaving maxDistance %@",shoe.maxDistance);
    shoe.startDistance = [NSNumber numberWithFloat:[startDistance.text floatValue]];
    shoe.expirationDate = expirationDate;
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
    NSLog(@"Made it to textFieldShouldReturn");
    return YES;
}

// ==========================================================================================
// end dismiss keyboards
// ==========================================================================================


- (IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // If our device has a camera, we want to take a picture, otherwise we just pick from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    // Place image picker on the screen
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that will display the imagePicker
        imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        [imagePickerPopover setDelegate:self];
        
        // Display the popover controller, sender is the camera bar button item
        [imagePickerPopover presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    } else {
        // Place image picker on the screen
        [self presentModalViewController:imagePicker animated:YES];
    }
    
    
    // The image picker will be retained by ItemDetailViewController until it has been dismissed
    [imagePicker release];
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
//    shoe.brand = brandField.text;
//    shoe.desc = name.text;
    
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
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    expPickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    expPickerView.tag = 10;
    expPickerView.datePickerMode = UIDatePickerModeDate;
//    [expPickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [actionSheet addSubview:expPickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancel:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [closeButton release];
    
    
    //[actionSheet showInView:self.view];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == expirationDateField) {
        [self callDP:nil];
        return NO;
    }
    
    return YES;    
}


- (void)actionSheetCancel:(id)sender
{

    expirationDate = self.expPickerView.date;
    NSLog(@"Expiration Date = %@",expirationDate);
    [expirationDateField setText:[self.expirationDateFormatter stringFromDate:self.expPickerView.date]];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
}


@end

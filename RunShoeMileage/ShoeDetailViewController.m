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
@synthesize brandField, shoe;
@synthesize expPickerView, expirationDateFormatter, expirationDate, startDate, currentDate;
@synthesize maxDistance;
@synthesize toolbar;
@synthesize startDateField, currentDateField, expirationDateField;

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
//    NSLog(@"entered shoeDetail didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
//    NSLog(@"leaving shoeDetail didReceiveMemoryWarning");    
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [brandField setText:shoe.brand];
    
    [maxDistance setText:[UserDistanceSetting displayDistance:[shoe.maxDistance floatValue]]];
    [startDistance setText:[UserDistanceSetting displayDistance:[shoe.startDistance floatValue]]];
    
    self.expirationDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.expirationDateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.expirationDateFormatter setTimeStyle:NSDateFormatterNoStyle];
//    expirationDateField.delegate = self;
    self.expirationDate = shoe.expirationDate;
    [expirationDateField setText:[self.expirationDateFormatter stringFromDate:shoe.expirationDate]];
    self.startDate = shoe.startDate;
    [startDateField setText:[self.expirationDateFormatter stringFromDate:shoe.startDate]];
//    NSLog(@"Will Appear Date = %@",shoe.expirationDate);
    
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

}


- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    shoe.brand = brandField.text;
    shoe.maxDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:maxDistance.text]];
 //   NSLog(@"Leaving maxDistance %@",shoe.maxDistance);
    shoe.startDistance = [NSNumber numberWithFloat:[UserDistanceSetting enterDistance:startDistance.text]];
    shoe.expirationDate = expirationDate;
    shoe.startDate = self.startDate;
//        NSLog(@"Will Disappear Start Date = %@",self.expPickerView.date);
//    NSLog(@"Leaving Date = %@",shoe.expirationDate);
//    NSLog(@"************** Leaving Detail View ************");
    
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
    [super viewDidUnload];
//    NSLog(@"entering ShoeDetailViewController viewDidUnload");
    [shoe release];
    shoe = nil;
    
//    [expPickerView release];
//    expPickerView = nil;
    
//    [expirationDateFormatter release];
//    expirationDateFormatter = nil;
    
    [expirationDate release];
    expirationDate = nil;
    
    [startDate release];
    startDate = nil;
    
    [currentDate release];
    currentDate = nil;
    
//    [currentDateField release];
//    currentDateField = nil;
    
    [maxDistance release];
    maxDistance = nil;
    
    [name release];
    name = nil;
    
    [maxDistance release];
    maxDistance = nil;
    
//    [expirationDateField release];
//    expirationDateField = nil;
    
    [startDistance release];
    startDistance = nil;
    
    [brandField release];
    brandField = nil;
    
    [imageView release];
    imageView = nil;
    
    [toolbar release];
    toolbar = nil;
    
//    [startDateField release];
//    startDateField = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
//    NSLog(@"entering ShoeDetailViewController dealloc");
//    NSLog(@"IN exp date field retain count = %d",[expirationDateField retainCount]);
//    NSLog(@"release shoe");
    [shoe release];
//    [expPickerView release];
 //   NSLog(@"release expdateformatter");
//    [expirationDateFormatter release];
//    NSLog(@"release expiration date");
    [expirationDate release];
 //   NSLog(@"release start date");
    [startDate release];
//    NSLog(@"BEFORE current date field retain count = %d",[expirationDateField retainCount]);    
//    NSLog(@"release current date");
    [currentDate release];
//    NSLog(@"release current date field");
//    [currentDateField release]; ***** current date field is really pointing to either start or expiration date
//    NSLog(@"AFTER current date field retain count = %d",[expirationDateField retainCount]);    
//    NSLog(@"release maxdistance");
    [maxDistance release];
//    NSLog(@"release name");
    [name release];
//    NSLog(@"release expiration date field");
//    NSLog(@"BEFORE exp date field retain count = %d",[expirationDateField retainCount]);
    [expirationDateField release];
//    NSLog(@"AFTER exp date field retain count = %d",[expirationDateField retainCount]);
//    NSLog(@"release startdistance");
    [startDistance release];
//    NSLog(@"release brand field");
    [brandField release];
//    NSLog(@"release imageview");
    [imageView release];
//    NSLog(@"release toolbar");
    [toolbar release];
//    NSLog(@"release startdatefield");
    [startDateField release];
    [super dealloc];
//    NSLog(@"Leaving ShoeDetailViewController dealloc");
//    NSLog(@"OUT exp date field retain count = %d",[expirationDateField retainCount]);
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
 //       NSLog(@"Picture Actionsheet Button = %i",buttonIndex);
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
                [pictureActionSheet release];
                return;
        }
         // If our device has a camera, we want to take a picture, otherwise we just pick from photo library
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
        [pictureActionSheet release];
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
    
    [shoe setThumbnailDataFromImage:image width:143 height:96];
    
    // Take image picker off the screen - You must call this dismiss method
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)save:(id)sender
{
    shoe.brand = brandField.text;
            
//    NSLog(@"%@", shoe.brand);
    
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
    
//    NSLog(@"callDP sender = %@", sender);
    currentDateField = sender;
    
    dateActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [dateActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    expPickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    expPickerView.tag = 10;
    expPickerView.datePickerMode = UIDatePickerModeDate;
    expPickerView.date = currentDate;
//    [expPickerView addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    [dateActionSheet addSubview:expPickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(actionSheetCancelEZ:) forControlEvents:UIControlEventValueChanged];
    [dateActionSheet addSubview:closeButton];
    [closeButton release];
    
    
    //[actionSheet showInView:self.view];
    [dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [dateActionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [dateActionSheet release];
    [expPickerView release];

//    NSLog(@"leaving CallDP");
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == expirationDateField) {
        self.currentDate = expirationDate;
        [self callDP:expirationDateField];
//        NSLog(@"Writing Expiration Date to local variable = %@",expirationDate);
        return NO;
    }
    
    if (textField == startDateField) {
        self.currentDate = startDate;
        [self callDP:startDateField];
//        NSLog(@"Writing Start Date to local variable = %@",startDate);
        return NO;
    }
    
    return YES;    
}


- (void)actionSheetCancelEZ:(id)sender
{


    if (currentDateField == startDateField){
            self.startDate = self.expPickerView.date;
        }
    
    if (currentDateField == expirationDateField) {
            self.expirationDate = self.expPickerView.date;
        }
    
//    NSLog(@"actionSheetCancel - Current Date = %@",self.currentDate);
//    NSLog(@"Start Date = %@",self.startDate);
    [currentDateField setText:[self.expirationDateFormatter stringFromDate:self.expPickerView.date]];
    [dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
}


@end

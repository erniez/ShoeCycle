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
//    [brandField setText:testBrandString];
//    [name setText:testNameString];
    [brandField setText:shoe.brand];
    [name setText:shoe.desc];
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [expirationDate release];
    expirationDate = nil;
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
    [expirationDate release];
    [startDistance release];
    [brandField release];
    [imageView release];
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
    
    // This line of code will generate 2 warnings right now, ignore them
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
    [[ImageStore defaultImageStore] setImage:image forKey:[shoe imageKey]];

    // Put that image onto the screen in our image view
    [imageView setImage:image];
    
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
//    [[PossessionStore defaultStore] removePossession:possession];
    
    // This message gets forwarded to the parentViewController

    [[ShoeStore defaultStore] removeShoe:shoe];
    [self dismissModalViewControllerAnimated:YES];
    
//    if ([delegate respondsToSelector:@selector(itemDetailViewControllerWillDismiss:)])
 //       [delegate itemDetailViewControllerWillDismiss:self];
}

@end

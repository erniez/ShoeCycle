//
//  EditShoesViewController.m
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditShoesViewController.h"
#import "ShoeDetailViewController.h"
#import "ShoeCycleAppDelegate.h"
#import "ShoeStore.h"
#import "Shoe.h"
#import "UserDistanceSetting.h"
#import "UIUtilities.h"
#import "UIColor+ShoeCycleColors.h"
#import "EditShoesCell.h"
#import "GlobalStringConstants.h"
#import "AnalyticsLogger.h"


@interface EditShoesViewController ()

@property (nonatomic, strong) UIView *helpBubble;
@property (nonatomic) NSInteger editingSelectedShoe; // We need this for when we're in editing mode, and we switch tabs.
@property (nonatomic) BOOL animatingDeletion;

@end


@implementation EditShoesViewController
//@synthesize testBrandArray, testNameArray;


- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
      
    }
    return self;
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentShoe = [UserDistanceSetting getSelectedShoe];
    self.tableView.contentMode = UIViewContentModeTop;
    [self.helpBubble removeFromSuperview];
    self.helpBubble = nil;
    
    NSInteger rowSelect = self.isEditing ? self.editingSelectedShoe : currentShoe;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowSelect inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSInteger shoeCount = [[[ShoeStore defaultStore] allShoes] count];
    if (shoeCount == 0)
    {
        [self showHelpBubble];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:kShoeDataDidChange object:nil];

    self.editingSelectedShoe = -1;
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                            target:self
                            action:@selector(addNewShoe:)];
    [self.navigationItem setRightBarButtonItem:bbi];
    [self.navigationItem setTitle:@"Add/Edit Shoes"];
    [self.navigationItem setLeftBarButtonItem:[self editButtonItem]];
    [UIUtilities setShoeCyclePatternedBackgroundOnView:self.view];
    
    UINib *cellNib = [UINib nibWithNibName:@"EditShoesCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"EditShoesCell"];
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (!editing && !self.animatingDeletion) {
        // need to check for valid data, because this gets hit multiple times on swipe deletes.
        currentShoe = self.editingSelectedShoe >=0 ? self.editingSelectedShoe : currentShoe;
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentShoe inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        [UserDistanceSetting setSelectedShoe:currentShoe];
        self.editingSelectedShoe = -1;
    }
    else if (editing){
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentShoe inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.editingSelectedShoe = currentShoe;
    }
}

// ******************************************************************************************
//  End of View Cycle
// ==========================================================================================


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cnt = [[[ShoeStore defaultStore] allShoes] count];
    // Check to see if current shoe was deleted, then set current shoe to top shoe.
    if (currentShoe >= cnt) {
        currentShoe = 0;
        [UserDistanceSetting setSelectedShoe:currentShoe];
    }
    return cnt;
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditShoesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditShoesCell" forIndexPath:indexPath];
    
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
    
    Shoe *shoe = [shoes objectAtIndex:indexPath.row];
    
    [cell configureForShoe:shoe];

    cell.accessoryType = UITableViewCellAccessoryDetailButton ;
    
	return cell;
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] init];
       
    NSArray *shoes = [[ShoeStore defaultStore] allShoes];
        
    [detailViewController setShoe:[shoes objectAtIndex:indexPath.row]];

    [[self navigationController] pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentShoe == indexPath.row) {
        return;
    }
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:currentShoe inSection:0] animated:YES];
    currentShoe = indexPath.row;
    if (self.isEditing) {
        self.editingSelectedShoe = indexPath.row;
    }
    else {
        [UserDistanceSetting setSelectedShoe:currentShoe];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ShoeStore *ss = [ShoeStore defaultStore];
        NSArray *shoes = [ss allShoes];
        Shoe *s = [shoes objectAtIndex:[indexPath row]];
        [ss removeShoe:s];

        NSInteger newShowSelectedIndex = self.editing ? self.editingSelectedShoe : currentShoe;
        if (indexPath.row < newShowSelectedIndex) {
            currentShoe--;
            self.editingSelectedShoe = -1;
            newShowSelectedIndex--;
        }
        // Save new shoe index only. Selection is handled by table view.
        [UserDistanceSetting setSelectedShoe:newShowSelectedIndex];

        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:newShowSelectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            self.animatingDeletion = NO;
        }];
       
        // remove row from table with animation
        self.animatingDeletion = YES;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
        
        [CATransaction commit];

        // show help bubble again if there are no more shoes.
        if ([shoes count] == 0)
        {
            [self performSelector:@selector(showHelpBubble) withObject:nil afterDelay:1.0];
        }
        [ss saveChangesEZ];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ShoeStore defaultStore] moveShoeAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    if (fromIndex == self.editingSelectedShoe) {
        self.editingSelectedShoe = toIndex;
    }
    else if (fromIndex < self.editingSelectedShoe && self.editingSelectedShoe <= toIndex) {
        self.editingSelectedShoe--;
    }
    else if (fromIndex > self.editingSelectedShoe && self.editingSelectedShoe >= toIndex) {
        self.editingSelectedShoe++;
    }
}


- (IBAction)addNewShoe:(id)sender
{
    NSTimeInterval secondsInSixMonths = 6 * 30.4 * 24 * 60 * 60;
    
    Shoe *newShoe = [[ShoeStore defaultStore] createShoe];
    ShoeDetailViewController *detailViewController = [[ShoeDetailViewController alloc] initForNewItem:YES];

    newShoe.maxDistance = [NSNumber numberWithFloat:350];
    newShoe.startDate = [NSDate date];
    newShoe.expirationDate = [newShoe.startDate dateByAddingTimeInterval:secondsInSixMonths];    
    
    [detailViewController setShoe:newShoe];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:NULL];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:NULL];
    
    NSArray *items = [NSArray arrayWithObjects:camera, spacer, trash, nil];
    
    [toolBar setItems:items animated:YES];
    
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [[AnalyticsLogger sharedLogger] logEventWithName:kAddShoeEvent userInfo:nil];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)showHelpBubble
{
    if (!self.helpBubble)
    {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(190, 20, 120, 90)];
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [helpLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        helpLabel.numberOfLines = 0;
        helpLabel.text = @"Please press \"+\" button to add a shoe.";
        helpLabel.textColor = [UIColor whiteColor];
        containerView.layer.borderColor = [UIColor shoeCycleOrange].CGColor;
        containerView.layer.borderWidth = 2.0;
        containerView.layer.cornerRadius = 5.0;
        
        helpLabel.center = CGPointMake(containerView.bounds.size.width/2, containerView.bounds.size.height/2);
        [containerView addSubview:helpLabel];
        
        containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [self.view addSubview:containerView];
        
        UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        arrowView.backgroundColor = [UIColor shoeCycleOrange];
        arrowView.transform = CGAffineTransformMakeRotation(M_PI/4);
        
        UIView *arrowContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        arrowContainer.clipsToBounds = YES;
        
        CGFloat yPosition = -9;
        CGFloat xPosition = containerView.bounds.size.width - 24;
        
        arrowView.center = CGPointMake(arrowContainer.bounds.size.width/2, arrowContainer.bounds.size.height);
        [arrowContainer addSubview:arrowView];
        
        CGRect containerFrame = arrowContainer.frame;
        containerFrame.origin.y = yPosition;
        containerFrame.origin.x = xPosition;
        arrowContainer.frame = containerFrame;
        
        [containerView addSubview:arrowContainer];
        
        self.helpBubble = containerView;
        
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.helpBubble.transform = CGAffineTransformIdentity;
        } completion:nil];

    }
}

#pragma mark - ShoeDetailViewControllerDelegate

- (void)shoeDetailViewControllerDataDidChange:(ShoeDetailViewController *)viewController
{
    [self.tableView reloadData];
}
@end

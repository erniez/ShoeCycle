//
//  EditShoesViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 12/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoeDetailViewController.h"
#import "ShoesTestData.h"
#import "Shoe.h"

@interface EditShoesViewController : UITableViewController<UITableViewDelegate>

@property NSInteger currentShoe;


- (IBAction)addNewShoe:(id)sender;

@end

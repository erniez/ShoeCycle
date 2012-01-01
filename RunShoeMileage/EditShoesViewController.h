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

@interface EditShoesViewController : UITableViewController
<UIApplicationDelegate>
{
    NSArray *testBrandArray;
    NSArray *testNameArray;
    ShoesTestData *testData;
    
}

@property (nonatomic, retain) NSArray *testBrandArray; 
@property (nonatomic, retain) NSArray *testNameArray; 

- (IBAction)addNewShoe:(id)sender;

@end

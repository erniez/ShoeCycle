//
//  RunHistoryViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoe.h"

@interface RunHistoryViewController : UITableViewController
<UITableViewDelegate>
{
    Shoe *shoe;
    NSMutableArray *runs;
    
    UIView *tableHeaderView;
}

@property (nonatomic, retain) Shoe *shoe;
@property (nonatomic, retain) NSMutableArray *runs;
@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;

@end

//
//  RunHistoryViewController.h
//  RunShoeMileage
//
//  Created by Ernie on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoe.h"

@interface RunHistoryViewController : UIViewController

@property (nonatomic, strong) Shoe *shoe;
@property (nonatomic, strong) NSMutableArray *runs;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;

@end

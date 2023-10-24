//
//  ShoesTestData.m
//  RunShoeMileage
//
//  Created by Ernie on 12/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShoesTestData.h"

@implementation ShoesTestData
@synthesize testBrandArray, testNameArray;

- (id)init
{
    self = [super init];
    if (self) {

        self.testBrandArray = [NSArray arrayWithObjects:@"Vibram", @"Brooks", @"Newton", nil];
        self.testNameArray = [NSArray arrayWithObjects:@"Five Fingers - Bikila", @"Ghost", @"Gravity", nil];  
        
        NSLog(@"initializing test data");
        NSLog(@"ShoeTestData rows = %d", [self.testNameArray count]);

    }
    
    return self;
}

@end

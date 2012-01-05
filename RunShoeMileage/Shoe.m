//
//  Shoe.m
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Shoe.h"

@implementation Shoe

@synthesize brand,desc,maxDistance,expirationDate,startDistance;
@synthesize imageKey;



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) dealloc
{
    [brand release];
    [desc release];
    [maxDistance release];
    [expirationDate release];
    [startDistance release];
    [imageKey release];
    
    [super dealloc];
}
@end

//
//  Shoe.h
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shoe : NSObject
{
    NSString *brand;
    NSString *desc;
    NSNumber *maxDistance;  // All distances are in miles.  Conversion only happens during View
    NSDate *expirationDate;
    NSNumber *startDistance; // The number of miles that the shoe may already have on it, before tracking
    NSString *imageKey;
}

@property (nonatomic, retain) NSString *brand;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSNumber *maxDistance;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) NSNumber *startDistance;
@property (nonatomic, copy) NSString *imageKey;

@end

//
//  Shoe.h
//  RunShoeMileage
//
//  Created by Ernie on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Shoe : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * imageKey;
@property (nonatomic, retain) NSNumber * maxDistance;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) NSNumber * startDistance;
@property (nonatomic, retain) NSNumber * totalDistance;

@end

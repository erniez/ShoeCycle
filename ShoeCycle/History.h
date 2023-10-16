//
//  History.h
//  RunShoeMileage
//
//  Created by Ernie on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shoe;

@interface History : NSManagedObject {

}
@property (nonatomic, strong) NSDate *runDate;
@property (nonatomic, strong) NSNumber *runDistance;
@property (nonatomic, strong) Shoe *shoe;

@end

//
//  ShoeStore.h
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shoe;

@interface ShoeStore : NSObject
{
    NSMutableArray *allShoes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (ShoeStore *)defaultStore;
- (BOOL)saveChanges;

#pragma mark Shoes
- (NSArray *)allShoes;
- (Shoe *)createShoe;
- (void)removeShoe:(Shoe *)s;
- (void)moveShoeAtIndex:(int)from toIndex:(int)to;
- (void)fetchShoesIfNecessary;

@end
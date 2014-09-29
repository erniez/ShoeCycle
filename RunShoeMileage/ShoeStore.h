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
@class History;

@interface ShoeStore : NSObject
{
    NSMutableArray *allShoes;
    NSMutableArray *allRunDistances;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (ShoeStore *)defaultStore;
- (BOOL)saveChangesEZ;

#pragma mark Shoes
- (NSArray *)allShoes;
- (NSArray *)allRunDistances;
- (Shoe *)createShoe;
- (void)removeShoe:(Shoe *)s;
- (void)moveShoeAtIndex:(NSInteger)from toIndex:(NSInteger)to;
- (void)fetchShoesIfNecessary;
- (void)setRunDistance:(float)dist;
- (void)removeHistory:(History *)h atShoe:(Shoe *)s;

@end
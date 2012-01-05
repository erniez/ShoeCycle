//
//  ShoeStore.m
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoeStore.h"
#import "Shoe.h"

static ShoeStore *defaultStore = nil;

@implementation ShoeStore


+ (ShoeStore *)defaultStore
{
    if (!defaultStore) {
        // Create the singleton
        defaultStore = [[super allocWithZone:NULL] init];
    }
    return defaultStore;
}


// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}


- (id)init
{
    // If we already have an instance of PossessionStore ...
    if (defaultStore) {
        // ... then return the existing one
        return defaultStore;
    }
    
    self = [super init];
    if (self) {
        allShoes = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)retain
{
    // Do nothing
    return self;
}


- (void)release
{
    // Do nothing
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}


- (NSArray *)allShoes
{
    return allShoes;
}


- (void)removeShoe:(Shoe *)s
{
    [allShoes removeObjectIdenticalTo:s];
    return;
}

- (Shoe *)createShoe
{
    Shoe *s = [[Shoe alloc] init];
    [allShoes addObject:s];
    return s;
}


- (void)moveShoeAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved
    Shoe *s = [allShoes objectAtIndex:from];
    
    [s retain];
    
    // Remove s from array, it is automatically sent release
    [allShoes removeObjectAtIndex:from];
     
    // Insert s in array at new location, retained by array
    [allShoes insertObject:s atIndex:to];
    
    [s release];
}

@end

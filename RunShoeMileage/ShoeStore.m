//
//  ShoeStore.m
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoeStore.h"
#import "ImageStore.h"
#import "Shoe.h"
#import "History.h"
#import "FileHelpers.h"

@implementation ShoeStore


+ (ShoeStore *)defaultStore
{
    static ShoeStore *defaultStore = nil;
    
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
    self = [super init];
    // If we already have an instance of ShoeStore ...
    if (self) {
  
        // Read in TreadTracker.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog (@"model = %@", model);
    
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
        // Where does the SQLite file go?
        NSString *path = pathInDocumentDirectory(@"store.data");
        NSURL *storeURL = [NSURL fileURLWithPath:path];
    
        NSError *error = nil;
    
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
    
        // Create the manage object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
    
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
    }

    return self;
}


- (NSArray *)allShoes
{
    [self fetchShoesIfNecessary];
    return allShoes;
}


- (void)removeShoe:(Shoe *)s
{
    NSString *key = [s imageKey];
    [[ImageStore defaultImageStore] deleteImageForKey:key];
    [context deleteObject:s];
    [allShoes removeObjectIdenticalTo:s];
    return;
}

- (Shoe *)createShoe
{
    // This ensures allPossessions is created
    [self fetchShoesIfNecessary];
    
    //    Possession *p = [Possession randomPossession];
    
    double order;
    if ([allShoes count] == 0) {
        order = 1.0;
    } else {
        order = [[[allShoes lastObject] orderingValue] doubleValue] + 1.0;
    }
//    NSLog(@"Adding after %d intems, order = %.2f", [allShoes count], order);
    
    Shoe *p = [NSEntityDescription insertNewObjectForEntityForName:@"Shoe"
                                                  inManagedObjectContext:context];
    
    [p setOrderingValue:[NSNumber numberWithDouble:order]];
    
    [allShoes addObject:p];
    
    return p;
}


- (void)moveShoeAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved
    Shoe *s = [allShoes objectAtIndex:from];
     
    // Remove s from array, it is automatically sent release
    [allShoes removeObjectAtIndex:from];
     
    // Insert s in array at new location, retained by array
    [allShoes insertObject:s atIndex:to];
 
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[[allShoes objectAtIndex:to - 1] orderingValue] doubleValue];
    } else {
        lowerBound = [[[allShoes objectAtIndex:1] orderingValue] doubleValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to < [allShoes count] - 1) {
        upperBound = [[[allShoes objectAtIndex:to + 1] orderingValue] doubleValue];
    } else {
        upperBound = [[[allShoes objectAtIndex:to - 1] orderingValue] doubleValue] + 2.0; 
    }
    
    // The order value will be the midpoint between the lower and upper bounds
    NSNumber *n = [NSNumber numberWithDouble:(lowerBound + upperBound)/2.0];
    
//    NSLog(@"Moving to order %@",n);
    [s setOrderingValue:n];
}


- (BOOL)saveChangesEZ
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}


- (void)fetchShoesIfNecessary
{
    if (!allShoes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Shoe"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        allShoes = [[NSMutableArray alloc] initWithArray:result];
    }
}


- (NSString *)shoeArchivePath
{
    // The returned path will be Sandbox/Documents/shoes.data
    // Both the saving and loading methods will call this method to get the same path,
    // preventing a typo in the path name of either method
    
    return pathInDocumentDirectory(@"shoes.data");
}


- (void)setRunDistance:(float)dist
{
    NSManagedObject *history;
    
    history = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
    [history setValue:[NSNumber numberWithFloat:dist] forKey:@"runDistance"];
    
}


- (NSArray *)allRunDistances
{
    if (!allRunDistances) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"History"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        allRunDistances = [result mutableCopy];
    }
    return allRunDistances;
}


- (void)removeHistory:(History *)h atShoe:(Shoe *)s
{
    [context deleteObject:h];
    return;
}

@end

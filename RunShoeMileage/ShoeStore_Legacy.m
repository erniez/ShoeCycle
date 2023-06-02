//
//  ShoeStore.m
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoeStore_Legacy.h"
#import "ImageStore.h"
#import "Shoe.h"
#import "History.h"
#import "FileHelpers.h"
#import "UserDistanceSetting.h"

@interface ShoeStore_Legacy ()

@property (nonatomic) NSMutableArray *mAllShoes;
@property (nonatomic) NSMutableArray *allRunDistances;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSManagedObjectModel *model;

@end


@implementation ShoeStore_Legacy


+ (ShoeStore_Legacy *)defaultStore
{
    static ShoeStore_Legacy *defaultStore = nil;
    
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
        self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        EZLog (@"model = %@", self.model);
    
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    
        // Where does the SQLite file go?
        NSString *path = pathInDocumentDirectory(@"store.data");
        NSURL *storeURL = [NSURL fileURLWithPath:path];
    
        NSError *error = nil;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:options
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
    
        // Create the manage object context
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [self.context setPersistentStoreCoordinator:psc];
    
        // The managed object context can manage undo, but we don't need it
        [self.context setUndoManager:nil];
    }

    return self;
}


- (NSArray<Shoe *> *)allShoes
{
    [self fetchShoesIfNecessary];
    return self.mAllShoes;
}

- (NSArray<Shoe *> *)hallOfFameShoes
{
    // Erase all shoes so they get reloaded and reorderd.
    self.mAllShoes = nil;
    [self fetchShoesIfNecessary];
    NSPredicate *hallOfFamePredicate = [NSPredicate predicateWithBlock:^BOOL(Shoe   * _Nullable shoe, NSDictionary<NSString *,id> * _Nullable bindings) {
        return shoe.hallOfFame;
    }];
    return [self.allShoes filteredArrayUsingPredicate:hallOfFamePredicate];
}

- (NSArray<Shoe *> *)activeShoes
{
    // Erase all shoes so they get reloaded and reorderd.
    self.mAllShoes = nil;
    [self fetchShoesIfNecessary];
    NSPredicate *hallOfFamePredicate = [NSPredicate predicateWithBlock:^BOOL(Shoe   * _Nullable shoe, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !shoe.hallOfFame;
    }];
    return [self.allShoes filteredArrayUsingPredicate:hallOfFamePredicate];
}

- (Shoe *)getCurrentlyActiveShoe
{
    NSArray *shoes = [self activeShoes];
    Shoe *activeShoe;
    
    if ([shoes count]) {
        if (([shoes count]-1) >= [UserDistanceSetting getSelectedShoe]){
            activeShoe = [shoes objectAtIndex:[UserDistanceSetting getSelectedShoe]];
        }
        else {
            activeShoe = [shoes objectAtIndex:0];
        }
    }
    
    return activeShoe;
}

- (void)removeShoe:(Shoe *)s
{
    NSString *key = [s imageKey];
    [[ImageStore defaultImageStore] deleteImageForKey:key];
    [self.context deleteObject:s];
    [self.mAllShoes removeObjectIdenticalTo:s];
    return;
}

- (Shoe *)createShoe
{
    // This ensures allPossessions is created
    [self fetchShoesIfNecessary];
    
    //    Possession *p = [Possession randomPossession];
    
    double order;
    if ([self.mAllShoes count] == 0) {
        order = 1.0;
    } else {
        order = [[[self.mAllShoes lastObject] orderingValue] doubleValue] + 1.0;
    }
    EZLog(@"Adding after %lu intems, order = %.2f", (unsigned long)[self.mAllShoes count], order);
    
    Shoe *p = [NSEntityDescription insertNewObjectForEntityForName:@"Shoe"
                                                  inManagedObjectContext:self.context];
    
    [p setOrderingValue:[NSNumber numberWithDouble:order]];
    
    [self.mAllShoes addObject:p];
    
    return p;
}


- (void)moveShoeAtIndex:(NSInteger)from toIndex:(NSInteger)to
{
    if (from == to) {
        return;
    }

    NSMutableArray *activeShoes = [self.activeShoes mutableCopy];
    
    // Get pointer to object being moved
    Shoe *s = [activeShoes objectAtIndex:from];
     
    // Remove s from array, it is automatically sent release
    [activeShoes removeObjectAtIndex:from];
     
    // Insert s in array at new location, retained by array
    [activeShoes insertObject:s atIndex:to];
 
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[[activeShoes objectAtIndex:to - 1] orderingValue] doubleValue];
    } else {
        lowerBound = [[[activeShoes objectAtIndex:1] orderingValue] doubleValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to < [activeShoes count] - 1) {
        upperBound = [[[activeShoes objectAtIndex:to + 1] orderingValue] doubleValue];
    } else {
        upperBound = [[[activeShoes objectAtIndex:to - 1] orderingValue] doubleValue] + 2.0;
    }
    
    // The order value will be the midpoint between the lower and upper bounds
    NSNumber *n = [NSNumber numberWithDouble:(lowerBound + upperBound)/2.0];
    
    EZLog(@"Moving to order %@",n);
    [s setOrderingValue:n];
    [self saveChangesEZ];
}


- (BOOL)saveChangesEZ
{
    NSError *err = nil;
    BOOL successful = [self.context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}


- (void)fetchShoesIfNecessary
{
    if (!self.mAllShoes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"Shoe"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.mAllShoes = [[NSMutableArray alloc] initWithArray:result];
    }
}


- (NSString *)shoeArchivePath
{
    // The returned path will be Sandbox/Documents/shoes.data
    // Both the saving and loading methods will call this method to get the same path,
    // preventing a typo in the path name of either method
    
    return pathInDocumentDirectory(@"shoes.data");
}


- (void)updateTotalDistanceForShoe:(Shoe *)shoe
{
    float runTotal = [shoe.startDistance floatValue];
    if ([shoe.history count]) {
        NSMutableArray *runs = [[NSMutableArray alloc] initWithArray:[shoe.history allObjects]];
        NSInteger i = 0;
        do {
            History *tempHist = [runs objectAtIndex:i];
            runTotal = runTotal +  [tempHist.runDistance floatValue];
            EZLog (@"runDistance = %f",[tempHist.runDistance floatValue]);
            i++;
        } while (i < [shoe.history count]);
        EZLog(@"run total = %f",runTotal);
        shoe.totalDistance = [NSNumber numberWithFloat:runTotal];
    }
    else {
        shoe.totalDistance = [NSNumber numberWithFloat:runTotal];
    }
}


- (NSArray *)allRunDistances
{
    if (!self.allRunDistances) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[self.model entitiesByName] objectForKey:@"History"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        self.allRunDistances = [result mutableCopy];
    }
    return self.allRunDistances;
}


- (void)removeHistory:(History *)h atShoe:(Shoe *)s
{
    [self.context deleteObject:h];
    return;
}

- (void)moveToLastPlace:(Shoe *)shoe
{
    Shoe *lastShoe = [self.mAllShoes lastObject];
    if (lastShoe) {
        NSNumber *order = lastShoe.orderingValue;
        shoe.orderingValue = [NSNumber numberWithDouble:[order doubleValue] + 1];
        [self saveChangesEZ];
    }
}

@end

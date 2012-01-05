//
//  ShoeStore.h
//  RunShoeMileage
//
//  Created by Ernie on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Shoe;

@interface ShoeStore : NSObject
{
    NSMutableArray *allShoes;
}

+ (ShoeStore *)defaultStore;

- (NSArray *)allShoes;
- (Shoe *)createShoe;
- (void)removeShoe:(Shoe *)s;
- (void)moveShoeAtIndex:(int)from toIndex:(int)to;

@end
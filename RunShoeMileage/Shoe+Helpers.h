//
//  Shoe+Helpers.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/26/16.
//
//

#import "Shoe.h"
@class History;

@interface Shoe (Helpers)

/**
 Sorted run history. Most recent run is first.
 */
- (NSArray<History *> *)sortedRunHistory;

@end

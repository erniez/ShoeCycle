//
//  Shoe+Helpers.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/26/16.
//
//

#import "Shoe.h"
@class History;
@class WeeklyCollated;

@interface Shoe (Helpers)

/**
 Sorted run history. Sorting controlled by the ascending property
 */
- (NSArray<History *> *)sortedRunHistoryAscending:(BOOL)ascending;

- (NSArray<WeeklyCollated *> *)collatedRunHistoryByWeekAscending:(BOOL)ascending;

@end

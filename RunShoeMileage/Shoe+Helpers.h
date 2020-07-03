//
//  Shoe+Helpers.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/26/16.
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
+ (NSArray<History *> *)sortRunHistories:(NSArray<History *> *)histories Ascending:(BOOL)ascending;

- (NSArray<WeeklyCollated *> *)collatedRunHistoryByWeekAscending:(BOOL)ascending;
+ (NSArray<WeeklyCollated *> *)collatedRunHistories:(NSArray<History *> *)histories ByWeekAscending:(BOOL)ascending;

@end

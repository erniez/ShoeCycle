//
//  Shoe+Helpers.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/26/16.
//
//

#import "Shoe+Helpers.h"
#import "History.h"

@implementation Shoe (Helpers)

- (NSArray<History *> *)sortedRunHistory
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    
    NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:[self.history allObjects]];
    [sortedRuns sortUsingDescriptors:sortDescriptors];
    return [sortedRuns copy];
}

@end

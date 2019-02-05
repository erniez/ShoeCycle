//
//  Shoe+Helpers.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/26/16.
//
//

#import "Shoe+Helpers.h"
#import "History.h"
#import "ShoeCycle-Swift.h"

@implementation Shoe (Helpers)

- (NSArray<History *> *)sortedRunHistoryAscending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    
    NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:[self.history allObjects]];
    [sortedRuns sortUsingDescriptors:sortDescriptors];
    return [sortedRuns copy];
}

- (NSDictionary *)collatedRunHistoryByWeekAscending:(BOOL)ascending
{
    NSLog(@"Collating History");
    NSMutableDictionary *collatedDictionary  = [NSMutableDictionary new];
    NSMutableArray *sortedKeys = [NSMutableArray new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // We actually want the gregorian calendar here, because we want the first day of the week to be consistent.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // TODO: Make this configurable
    [calendar setFirstWeekday:2];  // Set Monday to be first day of the week.
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSArray *sortedRuns = [self sortedRunHistoryAscending:ascending];
    [sortedRuns enumerateObjectsUsingBlock:^(History  * _Nonnull history, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *beginningOfWeek = [history.runDate beginningOfWeekForCalendar:calendar];
        NSString *keyDate = [dateFormatter stringFromDate:beginningOfWeek];
//        NSLog(@"Key Date: %@, Actual Date: %@", keyDate, history.runDate);
//        NSLog(@"Beginning of the week: %@", beginningOfWeek);
        if (collatedDictionary[keyDate]) {
            WeeklyCollated *weeklyCollated = (WeeklyCollated *)collatedDictionary[keyDate];
            float oldValue = [weeklyCollated.runDistance floatValue];
            float newValue = [history.runDistance floatValue];
            NSNumber *newNumber = [NSNumber numberWithFloat:(oldValue + newValue)];
            weeklyCollated.runDistance = newNumber;
            collatedDictionary[keyDate] = weeklyCollated;
        }
        else {
            WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:beginningOfWeek runDistance:history.runDistance];
            collatedDictionary[keyDate] = weeklyCollated;
            [sortedKeys addObject:keyDate];
        }
    }];
    collatedDictionary[@"SortedKeys"] = [sortedKeys copy];
    return [collatedDictionary copy];
}

@end

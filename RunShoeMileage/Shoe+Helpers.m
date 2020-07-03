//
//  Shoe+Helpers.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/26/16.
//
//

#import "Shoe+Helpers.h"
#import "History.h"
#import "ShoeCycle-Swift.h"
#import "UserDistanceSetting.h"

@implementation Shoe (Helpers)

- (NSArray<History *> *)sortedRunHistoryAscending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    
    NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:[self.history allObjects]];
    [sortedRuns sortUsingDescriptors:sortDescriptors];
    return [sortedRuns copy];
}

+ (NSArray<History *> *)sortRunHistories:(NSArray<History *> *)histories Ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runDate" ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    
    NSMutableArray *sortedRuns = [[NSMutableArray alloc] initWithArray:histories];
    [sortedRuns sortUsingDescriptors:sortDescriptors];
    return [sortedRuns copy];
}

+ (NSArray<WeeklyCollated *> *)collatedRunHistories:(NSArray<History *> *)histories ByWeekAscending:(BOOL)ascending
{
    NSMutableArray *collatedArray = [NSMutableArray new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // We actually want the gregorian calendar here, because we want the first day of the week to be consistent.
    // i.e. Weekday 2 is Monday.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setFirstWeekday:[UserDistanceSetting getFirstDayOfWeek]];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSArray *sortedRuns = [self sortRunHistories:histories Ascending:ascending];
    [sortedRuns enumerateObjectsUsingBlock:^(History  * _Nonnull history, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *beginningOfWeek = [history.runDate beginningOfWeekForCalendar:calendar];
        WeeklyCollated *currentWeeklyCollated = collatedArray.lastObject;
        if (currentWeeklyCollated) {
            if (currentWeeklyCollated.date == beginningOfWeek) {
                float oldValue = [currentWeeklyCollated.runDistance floatValue];
                float newValue = [history.runDistance floatValue];
                NSNumber *newNumber = [NSNumber numberWithFloat:(oldValue + newValue)];
                currentWeeklyCollated.runDistance = newNumber;
            }
            else {
                // I think I just need to add 1 week to currentWeeklyDate.  If currentWeeklyDate + 1 != to beginningOfWeek
                // then save 0 mile week.  Iterate until equal then add current mileage for week.
                // OR figure out how many weeks are in between dates and create enough entries to fill the gap.
                NSArray<NSDate *> *zeroMileageDates = [self beginningOfWeeksInBetweenTwoDates:currentWeeklyCollated.date compareDate:history.runDate withCalendar:calendar];
                // Add zero weeks, if any
                [zeroMileageDates enumerateObjectsUsingBlock:^(NSDate * _Nonnull date, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSNumber *zeroNumber = [NSNumber numberWithFloat:0.0];
                    WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:date runDistance:zeroNumber];
                    [collatedArray addObject:weeklyCollated];
                }];
                WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:beginningOfWeek runDistance:history.runDistance];
                [collatedArray addObject:weeklyCollated];
            }
        }
        else {
            WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:beginningOfWeek runDistance:history.runDistance];
            [collatedArray addObject:weeklyCollated];
        }
    }];
    return [collatedArray copy];
}

- (NSArray<WeeklyCollated *> *)collatedRunHistoryByWeekAscending:(BOOL)ascending
{
    NSMutableArray *collatedArray = [NSMutableArray new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // We actually want the gregorian calendar here, because we want the first day of the week to be consistent.
    // i.e. Weekday 2 is Monday.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setFirstWeekday:[UserDistanceSetting getFirstDayOfWeek]];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSArray *sortedRuns = [self sortedRunHistoryAscending:ascending];
    [sortedRuns enumerateObjectsUsingBlock:^(History  * _Nonnull history, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *beginningOfWeek = [history.runDate beginningOfWeekForCalendar:calendar];
        WeeklyCollated *currentWeeklyCollated = collatedArray.lastObject;
        if (currentWeeklyCollated) {
            if (currentWeeklyCollated.date == beginningOfWeek) {
                float oldValue = [currentWeeklyCollated.runDistance floatValue];
                float newValue = [history.runDistance floatValue];
                NSNumber *newNumber = [NSNumber numberWithFloat:(oldValue + newValue)];
                currentWeeklyCollated.runDistance = newNumber;
            }
            else {
                // I think I just need to add 1 week to currentWeeklyDate.  If currentWeeklyDate + 1 != to beginningOfWeek
                // then save 0 mile week.  Iterate until equal then add current mileage for week.
                // OR figure out how many weeks are in between dates and create enough entries to fill the gap.
                NSArray<NSDate *> *zeroMileageDates = [Shoe beginningOfWeeksInBetweenTwoDates:currentWeeklyCollated.date compareDate:history.runDate withCalendar:calendar];
                // Add zero weeks, if any
                [zeroMileageDates enumerateObjectsUsingBlock:^(NSDate * _Nonnull date, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSNumber *zeroNumber = [NSNumber numberWithFloat:0.0];
                    WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:date runDistance:zeroNumber];
                    [collatedArray addObject:weeklyCollated];
                }];
                WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:beginningOfWeek runDistance:history.runDistance];
                [collatedArray addObject:weeklyCollated];
            }
        }
        else {
            WeeklyCollated *weeklyCollated = [[WeeklyCollated alloc] initWithDate:beginningOfWeek runDistance:history.runDistance];
            [collatedArray addObject:weeklyCollated];
        }
    }];
    return [collatedArray copy];
}

+ (NSArray<NSDate *> *)beginningOfWeeksInBetweenTwoDates:(NSDate *)priorDate compareDate:(NSDate*)compareDate withCalendar:(NSCalendar *)calendar
{
    NSDate *beginningOfWeekForPriorDate = [priorDate beginningOfWeekForCalendar:calendar];
    NSDate *beginningOfWeekForCompareDate = [compareDate beginningOfWeekForCalendar:calendar];
    NSMutableArray<NSDate *> *beginningOfWeeks = [NSMutableArray new];
    NSDateComponents *components = [NSDateComponents new];
    components.weekday = [UserDistanceSetting getFirstDayOfWeek];
    [calendar enumerateDatesStartingAfterDate:beginningOfWeekForPriorDate matchingComponents:components options:NSCalendarMatchNextTime usingBlock:^(NSDate * _Nullable date, BOOL exactMatch, BOOL * _Nonnull stop) {
        NSComparisonResult dateCompare = [date compare:beginningOfWeekForCompareDate];
        if (dateCompare == NSOrderedDescending || dateCompare == NSOrderedSame) {
            *stop = YES;
        }
        else {
            [beginningOfWeeks addObject:date];
        }
    }];
    return [beginningOfWeeks copy];
}

- (NSDate *)addOneWeekToDate:(NSDate *)date forCalendar:(NSCalendar *)calendar
{

    return [NSDate new];
}

@end

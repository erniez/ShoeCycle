//
//  DateUtilities.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/15/15.
//
//

#import "DateUtilities.h"

@implementation DateUtilities

+ (NSString *)monthStringFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *monthSymbols = [dateFormatter monthSymbols];
    return monthSymbols[month - 1];
}

@end

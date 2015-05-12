//
//  NSDate+UTCConversion.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/9/15.
//
//

#import "NSDate+UTCConversion.h"

@implementation NSDate (UTCConversion)

+ (NSString *)UTCTimeStamp:(NSDate *)localDate
{
    NSMutableString *timeStamp = [[NSMutableString alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    
//    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [timeStamp appendString:[dateFormatter stringFromDate:localDate]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [timeStamp appendString:@"T"];
    [timeStamp appendString:[dateFormatter stringFromDate:localDate]];
    [timeStamp appendString:@"Z"];
    
    return timeStamp;
}

+ (NSDate *)stringToDate:(NSString *)UTCDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *date = [formatter dateFromString:UTCDateString];
    return date;
}

- (NSString *)UTCTimeStamp
{
    return [NSDate UTCTimeStamp:self];
}

@end

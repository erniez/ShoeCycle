//
//  NSDate+UTCConversion.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/9/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (UTCConversion)

- (NSString *)UTCTimeStamp;
+ (NSString *)UTCTimeStamp:(NSDate *)localDate;
+ (NSDate *)stringToDate:(NSString *)UTCDateString;

@end

//
//  NSDate+UTCConversion.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/9/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (UTCConversion)

+ (NSString *)getUTCTimeStamp:(NSDate *)localDate;

@end

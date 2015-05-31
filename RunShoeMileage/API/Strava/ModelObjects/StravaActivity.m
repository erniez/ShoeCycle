//
//  StravaActivity.m
//  ShoeCycle
//
//  Created by El Guapo on 5/9/15.
//
//

#import "StravaActivity.h"
#import "NSDate+UTCConversion.h"

@implementation StravaActivity

- (instancetype)initWithName:(NSString *)name distance:(NSNumber *)distance startDate:(NSDate *)startDate;
{
    self = [super init];
    if (self) {
        _name = name;
        _distance = distance;
        _startDate = startDate;
    }
    return self;
}

- (NSNumber *)elapsed_time
{
    return @(0);
}

- (NSString *)type
{
    return @"run";
}

- (NSString *)start_date_local
{
    return [self.startDate UTCTimeStamp];
}
@end

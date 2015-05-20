//
//  StravaActivity+DistanceConversion.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/19/15.
//
//

#import "StravaActivity+DistanceConversion.h"
#import "UserDistanceSetting.h"

@implementation StravaActivity (DistanceConversion)

+ (NSNumber *)stravaDistanceFromAddDistance:(float)addDistance
{
    addDistance = [UserDistanceSetting convertMilesToMeters:addDistance];
    return @(addDistance);
}

@end

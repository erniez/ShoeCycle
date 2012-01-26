//
//  UserDistanceSetting.m
//  RunShoeMileage
//
//  Created by Ernie on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserDistanceSetting.h"

float const milesToKilometers = 1.609344;
float const kilometersToMiles = 0.621371;

NSString * const TreadTrackerDistanceUnitPrefKey = @"TreadTrackerDistanceUnitPrefKey";
// static NSInteger distanceUnit;

@implementation UserDistanceSetting

+ (NSInteger) getDistanceUnit
{
    NSInteger distanceUnit;
    
    distanceUnit = [[NSUserDefaults standardUserDefaults] integerForKey:TreadTrackerDistanceUnitPrefKey];
    return distanceUnit;
}


+ (void) setDistanceUnit:(NSInteger)setting
{
    [[NSUserDefaults standardUserDefaults]
     setInteger:setting
     forKey:TreadTrackerDistanceUnitPrefKey];
    return;
}


+ (NSString *) displayDistance:(float)runDistance
{
    if ([UserDistanceSetting getDistanceUnit]) {
        runDistance = runDistance * milesToKilometers;
    }
    
    return [NSString stringWithFormat:@"%.2f",runDistance];

}


+ (float) enterDistance:(NSString *)enterDistanceString
{
    float distance = [enterDistanceString floatValue];
    
    if ([self getDistanceUnit]) {
        distance = [enterDistanceString floatValue] * kilometersToMiles;
    }
    return distance;  // have to return value in miles
}


@end

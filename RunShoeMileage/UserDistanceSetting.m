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
NSString * const TreadTrackerUserDefineDistance1PrefKey = @"TreadTrackerUserDefineDistance1PrefKey";
NSString * const TreadTrackerUserDefineDistance2PrefKey = @"TreadTrackerUserDefineDistance2PrefKey";
NSString * const TreadTrackerUserDefineDistance3PrefKey = @"TreadTrackerUserDefineDistance3PrefKey";
NSString * const TreadTrackerUserDefineDistance4PrefKey = @"TreadTrackerUserDefineDistance4PrefKey";

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


+ (float) getUserDefinedDistance1
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:TreadTrackerUserDefineDistance1PrefKey];
}


+ (void) setUserDefinedDistance1:(float)setting
{
    [[NSUserDefaults standardUserDefaults]
     setFloat:setting
     forKey:TreadTrackerUserDefineDistance1PrefKey];
    return;
}


+ (float) getUserDefinedDistance2
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:TreadTrackerUserDefineDistance2PrefKey];
}


+ (void) setUserDefinedDistance2:(float)setting
{
    [[NSUserDefaults standardUserDefaults]
     setFloat:setting
     forKey:TreadTrackerUserDefineDistance2PrefKey];
    return;
}


+ (float) getUserDefinedDistance3
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:TreadTrackerUserDefineDistance3PrefKey];
}


+ (void) setUserDefinedDistance3:(float)setting
{
    [[NSUserDefaults standardUserDefaults]
     setFloat:setting
     forKey:TreadTrackerUserDefineDistance3PrefKey];
    return;
}


+ (float) getUserDefinedDistance4
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:TreadTrackerUserDefineDistance4PrefKey];
}


+ (void) setUserDefinedDistance4:(float)setting
{
    [[NSUserDefaults standardUserDefaults]
     setFloat:setting
     forKey:TreadTrackerUserDefineDistance4PrefKey];
    return;
}

@end

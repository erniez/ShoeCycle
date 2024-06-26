//
//  UserDistanceSetting.m
//  RunShoeMileage
//
//  Created by Ernie on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserDistanceSetting.h"
#import "GlobalStringConstants.h"


float const milesToKilometers = 1.609344;
float const milesToMeters = 1609.34;
float const kilometersToMiles = 0.621371;

NSString * const TreadTrackerDistanceUnitPrefKey = @"TreadTrackerDistanceUnitPrefKey";
NSString * const TreadTrackerUserDefineDistance1PrefKey = @"TreadTrackerUserDefineDistance1PrefKey";
NSString * const TreadTrackerUserDefineDistance2PrefKey = @"TreadTrackerUserDefineDistance2PrefKey";
NSString * const TreadTrackerUserDefineDistance3PrefKey = @"TreadTrackerUserDefineDistance3PrefKey";
NSString * const TreadTrackerUserDefineDistance4PrefKey = @"TreadTrackerUserDefineDistance4PrefKey";
NSString * const TreadTrackerSelecredShoePrefKey = @"TreadTrackerSelecredShoePrefKey";
NSString * const ShoeCycleHealthKitEnabledKey = @"ShoeCycleHealthKitEnabled";
NSString * const ShoeCycleStravaEnabledKey = @"ShoeCycleStravaEnabledKey";
NSString * const ShoeCycleFirstDayOfWeekKey = @"ShoeCycleFirstDayOfWeekKey";
NSString * const GraphAllShoesToggleKey = @"ShoeCycleGraphAllShoesToggle";


@implementation UserDistanceSetting

+ (NSInteger)getDistanceUnit
{
    NSInteger distanceUnit;
    
    distanceUnit = [[NSUserDefaults standardUserDefaults] integerForKey:TreadTrackerDistanceUnitPrefKey];
    return distanceUnit;
}

+ (NSString *)unitOfMeasure
{
    NSString *unitOfMeasure = [UserDistanceSetting getDistanceUnit] ? @"km" : @"miles";
    return unitOfMeasure;
}


+ (void) setDistanceUnit:(NSInteger)setting
{
    [[NSUserDefaults standardUserDefaults]
     setInteger:setting
     forKey:TreadTrackerDistanceUnitPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)getFirstDayOfWeek
{
    NSInteger firstDayOfWeek = [[NSUserDefaults standardUserDefaults] integerForKey:ShoeCycleFirstDayOfWeekKey];
    if (firstDayOfWeek) {
        return firstDayOfWeek;
    }
    firstDayOfWeek = 2; // default to Monday
    [self setFirstDayOfWeek:firstDayOfWeek];
    return firstDayOfWeek;
}

+ (void)setFirstDayOfWeek:(NSInteger)setting
{
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:ShoeCycleFirstDayOfWeekKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) displayDistance:(float)runDistance
{
    if ([UserDistanceSetting getDistanceUnit]) {
        runDistance = runDistance * milesToKilometers;
    }
    
    NSString *returnString = [NSString stringWithFormat:@"%.2f", runDistance]; // Need to chop off anything below two decimal points
    runDistance = [returnString floatValue];                                   // or else numbers will display wrong (zeroes will drop)
    
    float testForDecimal = runDistance - (int)runDistance;      // if there is no decimal, the code below will truncate the whole number zeroes
    if (testForDecimal == 0) {
        return [NSString stringWithFormat:@"%i",(int)runDistance];
    }
    
    {
        NSInteger index = (int)[returnString length] - 1;
        BOOL trim = FALSE;
        while (
               ([returnString characterAtIndex:index] == '0' || 
                [returnString characterAtIndex:index] == '.')
               &&
               index > 0)
        {
            index--;
            trim = TRUE;
        }
        if (trim) {
            returnString = [returnString substringToIndex: index +1];
        }    
        return returnString;
    }
}

+ (float)getDistanceFromMiles:(float)miles
{
    float runDistance = miles;
    if ([UserDistanceSetting getDistanceUnit]) {
        runDistance = miles * milesToKilometers;
    }
    return runDistance;
}


+ (float) enterDistance:(NSString *)enterDistanceString
{
    float distance = [enterDistanceString floatValue];
    
    if ([self getDistanceUnit]) {
        distance = [enterDistanceString floatValue] * kilometersToMiles;
    }
    return distance;  // have to return value in miles
}

+ (float)convertMilesToMeters:(float)miles
{
    return miles * milesToMeters;
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) getSelectedShoe
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:TreadTrackerSelecredShoePrefKey];
}


+ (void) setSelectedShoe:(NSInteger)shoeIndex
{
    [[NSUserDefaults standardUserDefaults]
        setInteger:shoeIndex
            forKey:TreadTrackerSelecredShoePrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getHealthKitEnabled
{
    // nil BOOLs are returned as NO, so no need to set a default value here.
    return [[NSUserDefaults standardUserDefaults] boolForKey:ShoeCycleHealthKitEnabledKey];
}

+ (void)setHealthKitEnabled:(BOOL)isEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:isEnabled forKey:ShoeCycleHealthKitEnabledKey];
}

+ (BOOL)isStravaConnected
{
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kStravaAccessToken];
    if (token) {
        return YES;
    }
    return NO;
}

+ (void)resetStravaConnection
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kStravaAccessToken];
}

+ (BOOL)graphAllShoeToggle
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GraphAllShoesToggleKey];
}

+ (void)setGraphAllShoeToggle:(BOOL)showAllShoes
{
    [[NSUserDefaults standardUserDefaults] setBool:showAllShoes forKey:GraphAllShoesToggleKey];
}
@end

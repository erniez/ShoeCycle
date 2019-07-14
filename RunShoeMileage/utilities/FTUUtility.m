//
//  FTUUtility.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/15.
//
//

#import "FTUUtility.h"

NSString * const kFTUStravaFeature = @"ShoeCycleFTUStravaFeature";
NSString * const kFTUSwipeFeature = @"ShoeCycleFTUSwipeFeature";
NSString * const kFTUEmailHistoryFeature = @"ShoeCycleFTUEmailHistoryFeature";
NSString * const kFTUHOFFeature = @"ShoeCycleFTUHOFFeature";
NSString * const kFTUCompletedFeatures = @"ShoeCycleFTUCompletedFeatures";

// Feature Strings
NSString * const kNewFeaturesInfov3_0String = @"You can integrate with Strava! Add your runs to Strava as easily as tapping the \"+\" button.  Just tap on the \"Setup\" tab to get started!";
NSString * const kNewFeaturesInfov3_0String2 = @"You can swipe between shoes just by by swiping up or down on the shoe image in the \"Add Distance\" screen.";
NSString * const kNewFeaturesInfov3_3String = @"You can export your run history as a CSV file via email!  Just tap \"Email Data\" at the bottom right of the Run History screen.";
NSString * const kNewFeaturesInfov4_0String = @"You can now add shoes to the Hall of Fame section, so they don't crowd your active sneakers.";

@implementation FTUUtility

+ (NSArray *)newFeatures
{
    NSMutableArray *allFeatures = [[[self class] featureKeys] mutableCopy];
    [allFeatures removeObjectsInArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kFTUCompletedFeatures]];
    if ([allFeatures count] == 0) {
        return [NSArray array];
    }
    return allFeatures;
}

+ (void)completeFeature:(NSString *)featureKey
{
    NSMutableArray *completedFeatures = [NSMutableArray new];
    [completedFeatures addObjectsFromArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kFTUCompletedFeatures]];
    [completedFeatures addObject:featureKey];
    [[NSUserDefaults standardUserDefaults] setObject:[completedFeatures copy] forKey:kFTUCompletedFeatures];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)featureTextForFeatureKey:(NSString *)featureKey
{
    return [[self class] featureDictionary][featureKey];
}

+ (NSArray<NSString *> * __nonnull)featureKeys
{
    return @[kFTUHOFFeature, kFTUEmailHistoryFeature, kFTUSwipeFeature];
}

+ (NSDictionary *)featureDictionary
{
    return @{
                 kFTUSwipeFeature : kNewFeaturesInfov3_0String2,
                 kFTUEmailHistoryFeature : kNewFeaturesInfov3_3String,
                 kFTUHOFFeature : kNewFeaturesInfov4_0String
             };
}

@end

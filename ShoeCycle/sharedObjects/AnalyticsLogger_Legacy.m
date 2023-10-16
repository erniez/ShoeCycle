//
//  AnalyticsLogger.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/7/15.
//
//

#import "AnalyticsLogger_Legacy.h"
@import Firebase;

// Event Constants
NSString * const kLogMileageEvent = @"log_mileage";
NSString * const kStravaEvent = @"log_mileage_strava";
NSString * const kHealthKitEvent = @"log_mileage_health_kit";
NSString * const kAddShoeEvent = @"add_shoe";
NSString * const kShoePictureAddedEvent = @"add_shoe_picture";
NSString * const kShowHistoryEvent = @"show_history";
NSString * const kShowFavoriteDistancesEvent = @"show_favorite_distances";
NSString * const kAddToHOFEvent = @"add_to_HOF";
NSString * const kRemoveFromHOFEvent = @"remove_from_HOF";

// User Info Keys
NSString * const kMileageNumberKey = @"mileage";
NSString * const kTotalMileageNumberKey = @"total_mileage";
NSString * const kNumberOfFavoritesUsedKey = @"number_of_favorites";
NSString * const kMileageUnitKey = @"distance_unit";

@implementation AnalyticsLogger_Legacy

+ (instancetype)sharedLogger
{
    static AnalyticsLogger_Legacy *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [AnalyticsLogger_Legacy new];
    });
    return sharedLogger;
}

- (void)logEventWithName:(NSString *)name userInfo:(nullable NSDictionary<NSString *,id> *)userInfo
{
#ifndef DEBUG
    [FIRAnalytics logEventWithName:name parameters:userInfo];
#endif
}

@end

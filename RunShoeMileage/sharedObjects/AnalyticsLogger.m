//
//  AnalyticsLogger.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/7/15.
//
//

#import "AnalyticsLogger.h"
@import Firebase;

// Event Constants
NSString * const kLogMileageEvent = @"LogMileageEvent";
NSString * const kLogTotalMileageEvent = @"LogTotalMileageEvent";
NSString * const kStravaEvent = @"StravaEvent";
NSString * const kHealthKitEvent = @"HealthKitEvent";
NSString * const kAddShoeEvent = @"AddShoeEvent";
NSString * const kShoePictureAddedEvent = @"ShoePictureAddedEvent";
NSString * const kShowHistoryEvent = @"ShowHistoryEvent";
NSString * const kShowFavoriteDistancesEvent = @"ShowFavoriteDistancesEvent";
NSString * const kAddToHOFEvent = @"AddToHOFEvent";
NSString * const kRemoveFromHOFEvent = @"RemoveFromHOFEvent";

// User Info Keys
NSString * const kMileageNumberKey = @"numberOfMiles";
NSString * const kTotalMileageNumberKey = @"totalMiles";
NSString * const kNumberOfFavoritesUsedKey = @"numberOfFavorites";

@implementation AnalyticsLogger

+ (instancetype)sharedLogger
{
    static AnalyticsLogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [AnalyticsLogger new];
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

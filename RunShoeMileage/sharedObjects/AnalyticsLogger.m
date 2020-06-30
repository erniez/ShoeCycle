//
//  AnalyticsLogger.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/7/15.
//
//

#import "AnalyticsLogger.h"
#import <FirebaseCrashlytics/FirebaseCrashlytics.h>

// Event Constants
NSString * const kLogMileageEvent = @"LogMileageEvent_ShoeCycle";
NSString * const kLogTotalMileageEvent = @"LogTotalMileageEvent_ShoeCycle";
NSString * const kStravaEvent = @"StravaEvent_ShoeCycle";
NSString * const kHealthKitEvent = @"HealthKitEvent_ShoeCycle";
NSString * const kAddShoeEvent = @"AddShoeEvent_ShoeCycle";
NSString * const kShoePictureAddedEvent = @"ShoePictureAddedEvent_ShoeCycle";
NSString * const kShowHistoryEvent = @"ShowHistoryEvent_ShoeCycle";
NSString * const kShowFavoriteDistancesEvent = @"ShowFavoriteDistancesEvent_ShoeCylce";
NSString * const kAddToHOFEvent = @"AddToHOFEvent_Shoecycle";
NSString * const kRemoveFromHOFEvent = @"RemoveFromHOFEvent_Shoecycle";

// User Info Keys
NSString * const kMileageNumberKey = @"MileageNumber_ShoeCycleKey";
NSString * const kTotalMileageNumberKey = @"TotalMileageNumber_ShoeCycleKey";
NSString * const kNumberOfFavoritesUsedKey = @"NumberOfFavoritesUsed_ShoeCycleKey";

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
    // TODO: Update to Google Analytics
//    [Answers logCustomEventWithName:name customAttributes:userInfo];
#endif
}

@end

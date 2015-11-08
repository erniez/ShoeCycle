//
//  AnalyticsLogger.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 11/7/15.
//
//

#import "AnalyticsLogger.h"
#import <Crashlytics/Crashlytics.h>

// Event Constants
NSString * const kLogMileageEvent = @"shoecycleLogMileageEvent";
NSString * const kLogTotalMileageEvent = @"shoecycleLogTotalMileageEvent";
NSString * const kStravaEvent = @"shoecycleStravaEvent";
NSString * const kHealthKitEvent = @"shoecycleHealthKitEvent";
NSString * const kAddShoeEvent = @"shoecycleAddShoeEvent";
NSString * const kShoePictureAddedEvent = @"shoecycleShoePictureAddedEvent";
NSString * const kShowHistoryEvent = @"shoecycleShowHistoryEvent";

// User Info Keys
NSString * const kMileageNumberKey = @"shoecycleMileageNumberKey";
NSString * const kTotalMileageNumberKey = @"shoecycleTotalMileageNumberKey";

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
    [Answers logCustomEventWithName:name customAttributes:userInfo];
#endif
}

@end

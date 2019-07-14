//
//  AnalyticsLogger.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/7/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Event Constants
extern NSString * const kLogMileageEvent;
extern NSString * const kLogTotalMileageEvent;
extern NSString * const kStravaEvent;
extern NSString * const kHealthKitEvent;
extern NSString * const kAddShoeEvent;
extern NSString * const kShoePictureAddedEvent;
extern NSString * const kShowHistoryEvent;
extern NSString * const kShowFavoriteDistancesEvent;
extern NSString * const kAddToHOFEvent;
extern NSString * const kRemoveFromHOFEvent;

// User Info Keys
extern NSString * const kMileageNumberKey;
extern NSString * const kTotalMileageNumberKey;
extern NSString * const kNumberOfFavoritesUsedKey;

@interface AnalyticsLogger : NSObject

+ (instancetype)sharedLogger;
- (void)logEventWithName:(NSString *)name userInfo:(nullable NSDictionary<NSString *,id> *)userInfo;

@end
NS_ASSUME_NONNULL_END

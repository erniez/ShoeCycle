//
//  HealthKitManager.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 10/5/14.
//
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthKitManager : NSObject

@property (nonatomic, readonly) BOOL isHealthKitAvailable;
@property (nonatomic, readonly) HKAuthorizationStatus authorizationStatus;

- (void)initializeHealthKitForShoeCycleWithCompletion:(void(^)(BOOL success, UIAlertController *alertController))completion;
- (void)saveRunDistance:(double)runDistance date:(NSDate *)runDate metadata:(NSDictionary *)metadata;
- (void)fetchRunStepSourcesWithCompletion:(void(^)(HKSourceQuery *query, NSSet *sources, NSError *error))completion;
- (void)fetchShoeCylceRunStepQuantities:(void(^)(HKSampleQuery *query, NSArray *results, NSError *error))resultsHandler;

+ (HealthKitManager *)sharedManager;

@end

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

- (void)initializeHealthKitForShoeCycle;
- (void)saveRunDistance:(double)runDistance date:(NSDate *)runDate;

+ (HealthKitManager *)sharedManager;

@end

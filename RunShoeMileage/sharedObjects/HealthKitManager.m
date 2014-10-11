//
//  HealthKitManager.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 10/5/14.
//
//


#import "HealthKitManager.h"


@interface HealthKitManager ()

@property (nonatomic) BOOL isHealthKitAvailable;
@property (atomic, strong) HKHealthStore *healthStore;
@property (nonatomic) HKAuthorizationStatus authorizationStatus;
@property (atomic, strong) HKQuantityType *runQuantityType;

@end


@implementation HealthKitManager

+ (HealthKitManager *)sharedManager
{
    static HealthKitManager *healthKitManager = nil;
    static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    healthKitManager = [[HealthKitManager alloc] init];
});
    return healthKitManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isHealthKitAvailable = [HKHealthStore isHealthDataAvailable];
        if (_isHealthKitAvailable)
        {
            _healthStore = [[HKHealthStore alloc] init];
            
        }
    }
    return self;
}

- (void)initializeHealthKitForShoeCycle
{
    self.runQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    self.authorizationStatus = [self.healthStore authorizationStatusForType:self.runQuantityType];
    if (!self.authorizationStatus)
    {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:self.runQuantityType] readTypes:[NSSet setWithObject:self.runQuantityType]  completion:^(BOOL success, NSError *error) {
            self.authorizationStatus = success;
        }];
    }
}

- (void)saveRunDistance:(double)runDistance date:(NSDate *)runDate
{
    if ([[HealthKitManager sharedManager] authorizationStatus] == HKAuthorizationStatusSharingAuthorized)
    {
        HKQuantityType *runType = [[HealthKitManager sharedManager] runQuantityType];
        HKQuantity *runDistanceQuantity = [HKQuantity quantityWithUnit:[HKUnit mileUnit] doubleValue:runDistance];
        HKQuantitySample *runSample = [HKQuantitySample quantitySampleWithType:runType quantity:runDistanceQuantity startDate:runDate endDate:runDate];
        [self.healthStore saveObject:runSample withCompletion:nil];
    }
}
@end

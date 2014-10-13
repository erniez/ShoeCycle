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

- (void)saveRunDistance:(double)runDistance date:(NSDate *)runDate metadata:(NSDictionary *)metadata
{
    if ([[HealthKitManager sharedManager] authorizationStatus] == HKAuthorizationStatusSharingAuthorized)
    {
        HKQuantity *runDistanceQuantity = [HKQuantity quantityWithUnit:[HKUnit mileUnit] doubleValue:runDistance];
        HKQuantitySample *runSample = [HKQuantitySample quantitySampleWithType:self.runQuantityType quantity:runDistanceQuantity startDate:runDate endDate:runDate metadata:metadata];
        [self.healthStore saveObject:runSample withCompletion:nil];
    }
}

- (void)fetchRunStepSourcesWithCompletion:(void(^)(HKSourceQuery *query, NSSet *sources, NSError *error))completion
{
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:self.runQuantityType samplePredicate:nil completionHandler:completion];
    [self.healthStore executeQuery:sourceQuery];
}

- (void)fetchShoeCylceRunStepQuantities:(void(^)(HKSampleQuery *query, NSArray *results, NSError *error))resultsHandler
{
    NSPredicate *shoeCycleQuantities = [HKQuery predicateForObjectsFromSource:[HKSource defaultSource]];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:self.runQuantityType predicate:shoeCycleQuantities limit:0 sortDescriptors:nil resultsHandler:resultsHandler];
    
    [self.healthStore executeQuery:sampleQuery];
}

@end

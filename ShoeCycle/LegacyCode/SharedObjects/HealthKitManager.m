//
//  HealthKitManager.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/5/14.
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
            _runQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
            
        }
    }
    return self;
}

- (HKAuthorizationStatus)authorizationStatus
{
    return [self.healthStore authorizationStatusForType:self.runQuantityType];
}

- (void)initializeHealthKitForShoeCycleWithCompletion:(void (^)(BOOL success, UIAlertController *alertController))completion
{
    self.authorizationStatus = [self.healthStore authorizationStatusForType:self.runQuantityType];
    if (self.authorizationStatus == HKAuthorizationStatusNotDetermined || self.authorizationStatus == HKAuthorizationStatusSharingDenied)
    {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:self.runQuantityType] readTypes:[NSSet setWithObject:self.runQuantityType]  completion:^(BOOL success, NSError *error) {
            
            UIAlertController *alertController;
            
            // Check the authorization status again, in case the user changed it.
            self.authorizationStatus = [self.healthStore authorizationStatusForType:self.runQuantityType];
            if (error)
            {
                switch (error.code)
                {
                    case HKErrorUserCanceled:
                        error = [NSError errorWithDomain:@"appError" code:0 userInfo:@{NSLocalizedDescriptionKey : @"In order to send data to the Health App, you must give permission. Please try again."}];
                        break;
                        
                    default:
                        break;
                }
            }
            if (self.authorizationStatus == HKAuthorizationStatusSharingDenied && success)
            {
                error = [NSError errorWithDomain:@"appError" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Please enable HealthKit through your \"Settings\" app within the Privacy Section"}];
                success = NO;
            }
            if (error)
            {
                alertController = [UIAlertController alertControllerWithTitle:@"Error Accessing HealthKit:" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
            }
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success, alertController);
                });
            }
        }];
    }
}

- (void)saveRunDistance:(double)runDistance date:(NSDate *)runDate metadata:(NSDictionary *)metadata
{
    if ([[HealthKitManager sharedManager] authorizationStatus] == HKAuthorizationStatusSharingAuthorized)
    {
        HKQuantity *runDistanceQuantity = [HKQuantity quantityWithUnit:[HKUnit mileUnit] doubleValue:runDistance];
        HKQuantitySample *runSample = [HKQuantitySample quantitySampleWithType:self.runQuantityType quantity:runDistanceQuantity startDate:runDate endDate:runDate metadata:metadata];
        [self.healthStore saveObject:runSample withCompletion:^(BOOL success, NSError * _Nullable error) {
            ; // Intentional No Operation to silence warning
        }];
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

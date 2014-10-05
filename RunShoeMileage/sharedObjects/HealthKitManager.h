//
//  HealthKitManager.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 10/5/14.
//
//

#import <Foundation/Foundation.h>

@interface HealthKitManager : NSObject

@property (nonatomic, readonly) BOOL isHealthKitAvailable;

- (void)initializeHealthKitForShoeCycle;

@end

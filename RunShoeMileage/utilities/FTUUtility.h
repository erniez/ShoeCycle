//
//  FTUUtility.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/22/15.
//
//

#import <Foundation/Foundation.h>

@interface FTUUtility : NSObject

+ (NSString *)featureTextForFeatureKey:(NSString *)featureKey;
+ (NSArray *)newFeatures;
+ (void)completeFeature:(NSString *)featureKey;
+ (NSArray *)featureKeys;

@end

//
//  FTUUtility.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/15.
//
//

#import <Foundation/Foundation.h>

@interface FTUUtility : NSObject

+ (NSString *)featureTextForFeatureKey:(NSString *)featureKey;
+ (NSArray<NSString *> * _Nonnull)newFeatures;
+ (void)completeFeature:(NSString *)featureKey;
+ (NSArray<NSString *> * __nonnull)featureKeys;

@end

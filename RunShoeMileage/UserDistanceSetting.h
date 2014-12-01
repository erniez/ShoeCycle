//
//  UserDistanceSetting.h
//  RunShoeMileage
//
//  Created by Ernie on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDistanceSetting : NSObject

+ (NSInteger) getDistanceUnit;

+ (void) setDistanceUnit:(NSInteger)setting;

+ (NSString *) displayDistance:(float)runDistance;

+ (float) enterDistance:(NSString *)enterDistanceString;

+ (float) getUserDefinedDistance1;

+ (void) setUserDefinedDistance1:(float)setting;

+ (float) getUserDefinedDistance2;

+ (void) setUserDefinedDistance2:(float)setting;

+ (float) getUserDefinedDistance3;

+ (void) setUserDefinedDistance3:(float)setting;

+ (float) getUserDefinedDistance4;

+ (void) setUserDefinedDistance4:(float)setting;

+ (int) getSelectedShoe;

+ (void) setSelectedShoe:(NSInteger)shoeIndex;

+ (BOOL)getHealthKitEnabled;

+ (void)setHealthKitEnabled:(BOOL)isEnabled;

@end

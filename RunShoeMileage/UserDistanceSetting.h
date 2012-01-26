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

@end

//
//  StravaActivity+DistanceConversion.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/19/15.
//
//

#import "StravaActivity.h"

@interface StravaActivity (DistanceConversion)

/** 
 Takes a float value directly from the add distance text field and converts it to an NSNumber, in meters.
 All app units are in miles, iregardless of settings, so this method will convert from miles to meters.
*/
+ (NSNumber *)stravaDistanceFromAddDistance:(float)addDistance;

@end

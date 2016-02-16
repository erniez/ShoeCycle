//
//  GlobalStringConstants.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/12/15.
//
//

#import <Foundation/Foundation.h>
#import "GlobalStringConstants.h"

@implementation GlobalStringConstants

// User Defaults
NSString * const kUserStateUserDidLoadv2_2Key = @"UserStateUserDidLoadv2_2";
NSString * const kDoNotShowNewFeaturesKey = @"DoNotShowNewFeatures";
NSString * const kCurrentVersionNumber = @"CurrentVersionNumber";
NSString * const kPreviousVersionNumber = @"PreviousVersionNumber";


// API Keys and Tokens
NSString * const kCrashlyticsAPIKey = @"949e709fc52c311b695d5efc4d8c85064ad7a389";
NSString * const kStravaAccessToken = @"ShoeCycleStravaAccessToken"; // for user defaults


// Alert Messages
NSString * const kNewFeaturesInfov2_1String = @"You can now integrate with HealthKit! Check out your running progress in an easy to read chart in the Health app.  Just tap on the \"Setup\" tab to get started!";


// Notifications
NSString * const kShoeDataDidChange = @"ShoeCycleShoeDataDidChange";


@end
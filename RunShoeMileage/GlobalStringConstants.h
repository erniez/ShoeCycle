//
//  GlobalStringConstants.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 12/7/14.
//
//

#import <Foundation/Foundation.h>


// User Defaults
extern NSString * const kUserStateUserDidLoadv2_2Key;
extern NSString * const kDoNotShowNewFeaturesKey;
extern NSString * const kCurrentVersionNumber;
extern NSString * const kPreviousVersionNumber;


// API Keys and Tokens
extern NSString * const kCrashlyticsAPIKey;
extern NSString * const kStravaAccessToken; // for user defaults


// Alert Messages
extern NSString * const kNewFeaturesInfov2_1String;
extern NSString * const kShoeDataDidChange;


@interface GlobalStringConstants : NSObject

@end
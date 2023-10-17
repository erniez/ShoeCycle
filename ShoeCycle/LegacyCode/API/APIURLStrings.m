//
//  APIURLStrings.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/9/15.
//
//

#import "APIURLStrings.h"

NSString * const kStravaActivitiesURL = @"https://www.strava.com/api/v3/activities";
NSString * const kStravaAthleteURL = @"https://www.strava.com/api/v3/athlete";
NSString * const kStravaOAuthURL = @"https://www.strava.com/oauth/mobile/authorize?client_id=4002&redirect_uri=ShoeCycle%3A%2F%2Fshoecycleapp.com/callback%2F&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test";
NSString * const kStravaCallbackSubstringURL = @"shoecycleapp.com/callback";

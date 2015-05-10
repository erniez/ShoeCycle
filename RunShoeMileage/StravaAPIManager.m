//
//  StravaAPIManager.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/8/15.
//
//

#import "StravaAPIManager.h"
#import "AFNetworking.h"
#import "NSDate+UTCConversion.h"
#import "APIURLStrings.h"

@implementation StravaAPIManager
//3019584
- (void)sendActivityToStrava
{
    NSURL *baseURL = [NSURL URLWithString:kStravaActivitiesURL];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"ShoeCycle Run - Test" forKey:@"name"];
    [params setValue:@"0" forKey:@"elapsed_time"];
    [params setValue:@"8046.72" forKey:@"distance"];
    [params setValue:[[NSDate date] UTCTimeStamp] forKey:@"start_date_local"];
    [params setValue:@"run" forKey:@"type"];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer new] requestWithMethod:@"POST" URLString:kStravaActivitiesURL parameters:params error:nil];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"ShoeCycleStravaAccessToken"];
    NSString *authString = [NSString stringWithFormat:@"Bearer %@", token];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *athleteDataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"SUCCESS!");
    }];
    [athleteDataTask resume];
}

- (void)fetchAthlete
{
    NSURL *baseURL = [NSURL URLWithString:@"https://www.strava.com/api/v3/athlete"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"ShoeCycleStravaAccessToken"];
    NSString *authString = [NSString stringWithFormat:@"Bearer %@", token];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *athleteDataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"SUCCESS!");
    }];
    [athleteDataTask resume];
}
@end

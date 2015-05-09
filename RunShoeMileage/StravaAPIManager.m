//
//  StravaAPIManager.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/8/15.
//
//

#import "StravaAPIManager.h"
#import "AFNetworking.h"

@implementation StravaAPIManager
//3019584
- (void)sendActivityToStrava
{
    NSURL *baseURL = [NSURL URLWithString:@"https://www.strava.com/api/v3/activities"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSString stringWithFormat:@"ShoeCycle Run - %@",[NSDate date]] forKey:@"name"];
    [params setValue:@"0" forKey:@"elapsed_time"];
    [params setValue:@"8046.72" forKey:@"distance"];
    [params setValue:@"2015-05-08T10:02:13Z" forKey:@"start_date_local"];
    [params setValue:@"run" forKey:@"type"];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer new] requestWithMethod:@"POST" URLString:@"https://www.strava.com/api/v3/activities" parameters:params error:nil];
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

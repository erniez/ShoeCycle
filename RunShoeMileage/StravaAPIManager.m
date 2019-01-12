//
//  StravaAPIManager.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/8/15.
//
//

#import "StravaAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDate+UTCConversion.h"
#import "APIURLStrings.h"
#import "StravaActivity.h"
#import "GlobalStringConstants.h"

@implementation StravaAPIManager

- (void)sendActivityToStrava:(StravaActivity *)activity completion:(void (^)(NSError *))completion
{
    NSURL *baseURL = [NSURL URLWithString:kStravaActivitiesURL];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:activity.name forKey:@"name"];
    [params setValue:[activity.elapsed_time stringValue] forKey:@"elapsed_time"];
    [params setValue:[activity.distance stringValue] forKey:@"distance"];
    [params setValue:activity.start_date_local forKey:@"start_date_local"];
    [params setValue:activity.type forKey:@"type"];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer new] requestWithMethod:@"POST" URLString:kStravaActivitiesURL parameters:params error:nil];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kStravaAccessToken];
    NSString *authString = [NSString stringWithFormat:@"Bearer %@", token];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *athleteDataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
    [athleteDataTask resume];
}

- (void)fetchAthlete
{
    NSURL *baseURL = [NSURL URLWithString:@"https://www.strava.com/api/v3/athlete"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kStravaAccessToken];
    NSString *authString = [NSString stringWithFormat:@"Bearer %@", token];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *athleteDataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"SUCCESS!");
    }];
    [athleteDataTask resume];
}
@end

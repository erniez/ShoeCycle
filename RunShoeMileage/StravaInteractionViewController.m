//
//  StravaInteractionViewController.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/7/15.
//
//
#import "StravaInteractionViewController.h"
#import "AFNetworking.h"
#import "GlobalStringConstants.h"

@interface StravaInteractionViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSString *tempToken;
@property (nonatomic) AFHTTPSessionManager *httpSessionManager;

@end

@implementation StravaInteractionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    NSURL *targetURL = [NSURL URLWithString:@"https://www.strava.com/oauth/authorize?client_id=4002&response_type=code&redirect_uri=http://shoecycleapp.com/callback&scope=write"];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = request.URL;
    NSString *URLString = requestURL.absoluteString;
    if ([URLString containsString:@"shoecycleapp.com/callback"] && ![URLString containsString:@"redirect_uri"]){
        if ([URLString containsString:@"code"]) {
            NSArray *tempArray = [URLString componentsSeparatedByString:@"code="];
            self.tempToken = [tempArray lastObject];
            [self didReceiveTemporaryToken];
        }
    }
    return YES;
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:self completion:nil];
}


#pragma mark - Private Function

- (void)didReceiveTemporaryToken
{
    NSString *URLString = @"https://www.strava.com/oauth/token";
    NSDictionary *params = @{@"client_id" : @"4002", @"client_secret" : @"558112ea963c3427a387549a3361bd6677083ff9", @"code" : self.tempToken};
    [self.httpSessionManager POST:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [self saveAccessToken:responseObject[@"access_token"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        EZLog(@"Something Failed!!!");
    }];
}

- (void)saveAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kStravaAccessToken];
}
@end

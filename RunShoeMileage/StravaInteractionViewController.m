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
@property (nonatomic) BOOL connectionSuccessful;
@property (nonatomic) NSError *connectionError;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if (self.completion) {
        self.completion(self.connectionSuccessful, self.connectionError);
    }
    [self dismissViewControllerAnimated:self completion:nil];
}


#pragma mark - Private Methods

- (void)didReceiveTemporaryToken
{
    NSString *URLString = @"https://www.strava.com/oauth/token";
    NSDictionary *params = @{@"client_id" : @"4002", @"client_secret" : @"558112ea963c3427a387549a3361bd6677083ff9", @"code" : self.tempToken};
    [self.httpSessionManager POST:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [self saveAccessToken:responseObject[@"access_token"]];
        self.connectionSuccessful = YES;
        [self postSuccessMessage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.connectionError = error;
        [self cancelButtonTapped:nil];
    }];
}

- (void)saveAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kStravaAccessToken];
}

- (void)postSuccessMessage
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You have successfully connected to Strava!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Return to Setup" style:UIAlertControllerStyleAlert handler:^(UIAlertAction *action) {
        [weakSelf cancelButtonTapped:nil];
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end

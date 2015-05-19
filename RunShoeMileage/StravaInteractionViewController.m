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
#import "APIURLStrings.h"
#import "UIAlertController+CommonAlerts.h"
#import "MBProgressHUD.h"

static NSString * const kStravaClientID = @"4002";
static NSString * const kStravaClientIDkey = @"client_id";
static NSString * const kStravaSecret = @"558112ea963c3427a387549a3361bd6677083ff9";
static NSString * const kStravaSecretKey = @"client_secret";

@interface StravaInteractionViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSString *tempToken;
@property (nonatomic) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic) BOOL connectionSuccessful;
@property (nonatomic) NSError *connectionError;
@property (nonatomic, getter=isShowingHUD) BOOL showingHUD;

@end

@implementation StravaInteractionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    NSURL *targetURL = [NSURL URLWithString:kStravaOAuthURL];
    
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
    [self showHUD];
    
    NSURL *requestURL = request.URL;
    NSString *URLString = requestURL.absoluteString;
    if ([URLString containsString:kStravaCallbackSubstringURL] && ![URLString containsString:@"redirect_uri"]){
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
    [self hideHUD];
    [self dismissViewControllerAnimated:self completion:^{
        if (self.completion) {
            self.completion(self.connectionSuccessful, self.connectionError);
        }
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHUD];
    UIAlertController *alertController = [UIAlertController alertControllerWithOKButtonAndTitle:@"Network Connection Error" message:@"Sorry, you are not connected to the internet at this time. Please change your network settings or try again later."];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Private Methods

- (void)showHUD
{
    if (!self.isShowingHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.showingHUD = YES;
    }
}

- (void)hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.showingHUD = NO;
}

- (void)didReceiveTemporaryToken
{
    __weak typeof(self) weakSelf = self;
    NSString *URLString = @"https://www.strava.com/oauth/token";
    NSDictionary *params = @{kStravaClientIDkey : kStravaClientID, kStravaSecretKey : kStravaSecret, @"code" : self.tempToken};
    [self.httpSessionManager POST:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf saveAccessToken:responseObject[@"access_token"]];
        weakSelf.connectionSuccessful = YES;
        [weakSelf postSuccessMessage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.connectionError = error;
        [weakSelf cancelButtonTapped:nil];
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

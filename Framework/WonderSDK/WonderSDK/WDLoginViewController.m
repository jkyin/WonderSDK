//
//  WDLoginViewController.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDLoginViewController.h"
#import "WDURLParser.h"
#import "WDUserStore.h"
#import "WDLoadingView.h"
#import "WDConstants.h"

// Vendors
#import "WebViewJavascriptBridge.h"
#import "MBProgressHUD.h"

#define IS_DEVICE_PHONE  [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
#define IS_OS_8_0_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

NSString * const baseURL = @"http://192.168.1.251:8008/jsp/";
// NSString * const baseURL = @"http://218.17.158.13:3337/wonderCenter/jsp/";

@interface WDLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
// 登录中
@property (strong, nonatomic) WDLoadingView *loadingView;
@property (strong, nonatomic) UIButton *switchAccountButton;
@property (assign, nonatomic) BOOL isClickedSwitchAccount;
// 自适应键盘
@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGRect kbRect;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@end

@implementation WDLoginViewController

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat landscapeWidth = IS_OS_8_OR_LATER ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
        if (landscapeWidth == 480) {
            // 3.5 inch
            UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_480w"]];
            [self.view addSubview:background];
        } else if (landscapeWidth == 1024) {
            // iPad
            UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_1024w"]];
            [self.view addSubview:background];
        } else {
            // default 4' screen
            UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_568w"]];
            [self.view addSubview:background];
        }
        
        self.view.autoresizesSubviews = YES;
        _isClickedSwitchAccount = NO;
        
        CGPoint windowCenter = IS_OS_8_0_LATER ? CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)
                                               : CGPointMake(self.view.frame.size.height / 2.0f, self.view.frame.size.width / 2.0f);
        
        /* webView 设置 */
        _webView = IS_DEVICE_PHONE ? [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] : [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 540)];
        _webView.center = windowCenter;
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleBottomMargin
                                     );
//        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        _webView.scrollView.scrollEnabled = NO; // 禁用滚动
        _webView.scrollView.bounces = NO; // 禁用回弹
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        [self.view addSubview:_webView];

#if DEBUG
        [WebViewJavascriptBridge enableLogging];
#endif
        
        /* 接收 JS 消息 */
        __weak WDLoginViewController *weakSelf = self;
        self.javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            if ([data isKindOfClass:[NSString class]]) {
                [[WDUserStore sharedStore] removeUser:data];
            } else if ([data isKindOfClass:[NSNumber class]]){
                weakSelf.textFieldHeight = [(NSNumber *)data intValue];
            }
        }];
    }
    
    return self;
}

- (void)dealloc {
    // 移除 KVO 和通知
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除 delegate
    _webView.delegate = nil;
    _webView.scrollView.delegate = nil;
    // 移除 UIButton Target
    [_switchAccountButton removeTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
    
}

// 注册通知
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
}

#pragma mark - Public Methods

- (void)showLogin {
    if ([[WDUserStore sharedStore] lastUser]) {
        [self wonderLoginWithoutUI];
    } else {
        [self wonderLoginWithUI];
    }
}

#pragma mark - Private Methods

- (void)wonderLoginWithUI {
    NSURL *url = [NSURL URLWithString:@"login.jsp" relativeToURL:[NSURL URLWithString:baseURL]];
    //    NSURL *url = [NSURL URLWithString:@"http://218.17.158.13:19999/index.html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)wonderLoginWithoutUI {
    [_webView removeFromSuperview];
    NSString *urlString  = [NSString stringWithFormat:@"http://192.168.1.251:8008/api/userLogin?username=%@&password=%@",
                            [[WDUserStore sharedStore] lastUser].userName, [[WDUserStore sharedStore] lastUser].passWord];
    //    NSString *urlString  = [NSString stringWithFormat:@"http://218.17.158.13:3337/wonderCenter/api/userLogin?username=%@&password=%@",
    //                            [[WDUserStore sharedStore] lastUser].userName, [[WDUserStore sharedStore] lastUser].passWord];
    NSURL *url = [NSURL URLWithString:urlString];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)switchAccount {
    _isClickedSwitchAccount = YES;
    [_switchAccountButton removeFromSuperview];
    [_loadingView removeFromSuperview];
    [self.view addSubview:_webView];
    [self wonderLoginWithUI];
}

- (void)saveAccount {
    [[WDUserStore sharedStore] saveAccountChangesWithCompletionHandler:^(BOOL success) {
        NSLog(@"save succeed");
    }];
}

/* 正在登录 */
- (void)showLoadingProcess {
    [_webView removeFromSuperview];
    CGPoint windowCenter = IS_OS_8_0_LATER ? CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)
                            : CGPointMake(self.view.frame.size.height / 2.0f, self.view.frame.size.width / 2.0f);
    
    // loadingView setup
    _loadingView = IS_DEVICE_PHONE ? [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)]: [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    _loadingView.center = windowCenter;
    [self.view addSubview:_loadingView];
    
    // switchAccountButton setup
    _switchAccountButton = [UIButton buttonWithType:UIButtonTypeSystem]; // ios 7.0 later
    _switchAccountButton.frame = IS_DEVICE_PHONE ? CGRectMake(15, 15, 100, 30) : CGRectMake(30, 30, 150, 60);
    _switchAccountButton.backgroundColor = [UIColor colorWithRed:0.278 green:0.519 blue:0.918 alpha:1.000];
    _switchAccountButton.layer.masksToBounds = YES;
    _switchAccountButton.layer.cornerRadius = 5;
    _switchAccountButton.tintColor = [UIColor whiteColor];
    _switchAccountButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_switchAccountButton setTitle:@"切换帐号" forState:UIControlStateNormal];
    [_switchAccountButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchAccountButton];
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // UIApplication notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL);
    NSURL *url = request.URL;
    NSString *urlString = request.URL.absoluteString;
    
    // Direct Logins, Auto Register or Normal Register,
    // here startting load switch button and the login information.
    if ([@[@"userLogin", @"normalRegister"] containsObject:url.lastPathComponent]) {
        WDURLParser *urlParser = [[WDURLParser alloc] initWithURLString:urlString];
        [[WDUserStore sharedStore] setCurrentUserWithUsername:[urlParser valueForVariable:@"username"] andPassword:[urlParser valueForVariable:@"password"]];

        if ([WDUserStore sharedStore].currentUser) {
            [self showLoadingProcess];
        }
    }
    
    // Login Redirect, Tips Redirect or Register Redirect,
    // the Tips Redirect contains login result.
    if ([@[@"loginRedirect", @"tipsRedirect", @"registerRedirect"] containsObject:url.lastPathComponent]) {
        __weak WDLoginViewController *weakSelf = self;
        WDURLParser *urlParser = [[WDURLParser alloc] initWithURLString:urlString];
        NSString *value = [urlParser valueForVariable:@"command"];
        NSString *token = [urlParser valueForVariable:@"token"];
        
        // 2 seconds delay to handle login result mission.
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // login succeed
            if ([value isEqualToString:@"login_return_success"]) {
                if ([WDUserStore sharedStore].currentUser) {
                    [[WDUserStore sharedStore] addUser:[WDUserStore sharedStore].currentUser]; // save user account
                }
                
                //TODO: get token
                if (token && !_isClickedSwitchAccount) {
                    [weakSelf.delegate dialogDidSucceedWithToken:token];
                }
            }
            
            // login failed or register failed,
            // so you should return login screen.
            if ([@[@"login_return_fail", @"register_return_fail"] containsObject:value]) {
                [weakSelf.view addSubview:_webView];
            }
            
            // Tasks whatever whether login succeed or failed.
            [_switchAccountButton removeFromSuperview];
            [_loadingView stopAnimating];
            [_loadingView removeFromSuperview];
            _isClickedSwitchAccount = NO;
        });
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *lastPathComponent = _webView.request.URL.lastPathComponent;
    if ([lastPathComponent isEqualToString: @"login.jsp"]) {
        NSString *jsFunction = [NSString stringWithFormat:@"addBox(\"%@\")", [[WDUserStore sharedStore] stringWithJsonData]];
        [_webView stringByEvaluatingJavaScriptFromString:jsFunction];
    }
    
    if ([lastPathComponent isEqualToString:@"bindEmail.jsp"]) {
        if ([[WDUserStore sharedStore] lastUser]) {
            NSString *jsUserName = [NSString stringWithFormat:@"document.getElementById('nmid').value = '%@'", [[WDUserStore sharedStore] lastUser].userName];
            NSString *jsPassWord = [NSString stringWithFormat:@"document.getElementById('pwdid').value = '%@'", [[WDUserStore sharedStore] lastUser].passWord];
            [_webView stringByEvaluatingJavaScriptFromString:jsUserName];
            [_webView stringByEvaluatingJavaScriptFromString:jsPassWord];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
    // NSURLErrorCancelled == "Operation could not be completed", note NSURLErrorCancelled occurs when
    // the user clicks away before the page has completely loaded, if we find cases where we want this
    // to result in dialog failure (usually this just means quick-user), then we should add something
    // more robust here to account for differences in application needs
    if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) || ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        NSLog(@"error.domain 是 %@", error.domain);
    }
    
    switch (error.code) {
        case NSURLErrorCannotConnectToHost: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法连接服务器" delegate:nil cancelButtonTitle:@"请稍后重试" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case NSURLErrorTimedOut: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"连接超时" delegate:self cancelButtonTitle:@"重新连接" otherButtonTitles:nil];
            [alert show];
            break;
        }
    }
    
    NSLog(@"error.code: %ld", (long)error.code);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"textFieldHeight"]) {
        CGFloat distanceTextFieldToTop = CGRectGetMinY(_webView.frame) + self.textFieldHeight + 30;
        CGFloat offset = ([self currentScreenSize].height - CGRectGetHeight(_kbRect)) - distanceTextFieldToTop;
        NSLog(@"offset:%f", offset);
        CGPoint webViewCenter = _webView.center;
        webViewCenter.y +=  offset - 40;
        
        [UIView animateWithDuration:.25 animations:^{
            _webView.center = webViewCenter;
        }];
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _kbRect = [self.view convertRect:keyboardFrame fromView:self.view.window];
    
    CGRectGetMinY(_webView.frame);
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    CGPoint webViewCenter = _webView.center;
    webViewCenter.y = [self currentScreenSize].height / 2.0f;
    
    [UIView animateWithDuration:.25 animations:^{
        _webView.center = webViewCenter;
    }];
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"The %@ button was tapped.", [theAlert buttonTitleAtIndex:buttonIndex]);
    [self showLogin];
}

#pragma mark - Helper

- (CGSize)currentScreenSize {
    // iOS 8 simply adjusts the application frame to adapt to the current orientation and deprecated the concept of interface orientations
    if (!IS_OS_8_0_LATER) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGSize currentScreenSize = CGSizeMake(CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
            return currentScreenSize;
        }
    }
    
    return [UIScreen mainScreen].bounds.size;
}

@end


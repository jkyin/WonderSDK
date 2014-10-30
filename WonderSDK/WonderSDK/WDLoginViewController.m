//
//  WonderLoginViewController.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//
#if DEBUG
#import "FLEXManager.h"
#endif

#import "WDLoginViewController.h"
#import "WDURLParser.h"
#import "WDUserStore.h"
#import "WonderUser.h"
#import "WDLoadingView.h"

#import "WebViewJavascriptBridge.h"
#import "MBProgressHUD.h"

#define IS_DEVICE_PHONE  [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
#define IS_OS_8_0_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

NSString * const baseURL = @"http://192.168.1.251:8008/jsp/";
//NSString * const baseURL = @"http://218.17.158.13:3337/wonderCenter/jsp/";

@interface WDLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIButton *switchAccountButton;
@property (strong, nonatomic) WDLoadingView *loadingView;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) WonderUser *user;

@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGRect kbRect;
@property (assign, nonatomic) CGFloat webViewHeight;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

@end

@implementation WDLoginViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.view.autoresizesSubviews = YES;
    
#if DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
    
    CGPoint windowCenter = IS_OS_8_0_LATER ? CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)
                                           : CGPointMake(self.view.frame.size.height / 2.0f, self.view.frame.size.width / 2.0f);

    // webView setup
    _webView = IS_DEVICE_PHONE ? [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] : [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 540)];
    _webView.center = windowCenter;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleBottomMargin
                                 );
    _webView.layer.masksToBounds = YES;
    _webView.layer.cornerRadius = 15;
//    _webView.layer.shadowColor = [UIColor blackColor].CGColor;
//    _webView.layer.shadowOpacity = 0.5f; // 阴影不透明度
//    _webView.layer.shadowOffset = CGSizeMake(0, 5); // 阴影偏移量
//    _webView.layer.shadowRadius = 10.0f; // 阴影模糊半径
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.scrollEnabled = NO; // 禁用滚动
    _webView.scrollView.bounces = NO; // 禁用回弹
    [self.view addSubview:_webView];
    
    // receive JS messages
    _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[WDUserStore sharedStore] removeUser:data];
        } else if ([data isKindOfClass:[NSNumber class]]){
            self.textFieldHeight = [(NSNumber *)data intValue];
        }
        
    }];
    
    [self wonderLogin];
}

// 注册通知
- (void)viewWillAppear:(BOOL)animated {
    [self addObservers];
}

// 注销通知
- (void)viewWillDisappear:(BOOL)animated {
    [self removeObservers];
}

#pragma mark - Public methods

- (void)wonderLogin {
    if ([[WDUserStore sharedStore] lastUser]) {
        [self wonderLoginWithOutUI];
    } else {
        [self wonderLoginWithUI];
    }
}

- (void)wonderLoginWithUI {
    NSURL *url = [NSURL URLWithString:@"login.jsp" relativeToURL:[NSURL URLWithString:baseURL]];
//    NSURL *url = [NSURL URLWithString:@"http://jkyin.me/ghost"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)wonderLoginWithOutUI {
    [_webView removeFromSuperview];
    NSString *urlString  = [NSString stringWithFormat:@"http://192.168.1.251:8008/api/userLogin?username=%@&&password=%@",
                            [[WDUserStore sharedStore] lastUser].userName, [[WDUserStore sharedStore] lastUser].passWord];
    NSURL *url = [NSURL URLWithString:urlString];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Private method

- (void)switchAccount {
    [self.view addSubview:_webView];
    [self.switchAccountButton removeFromSuperview];
    [self.loadingView removeFromSuperview];
    [self wonderLoginWithUI];
}

- (void)saveAccount {
    [[WDUserStore sharedStore] saveAccountChangesWithCompletionHandler:^(BOOL success) {
        NSLog(@"save succeed");
    }];
}

// handle loading process
- (void)showLoadingProcess:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"showLoadingProcess"]) {
        [_webView removeFromSuperview];
        CGPoint windowCenter = IS_OS_8_0_LATER ? CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)
                                               : CGPointMake(self.view.frame.size.height / 2.0f, self.view.frame.size.width / 2.0f);
        
        // loadingView setup
        _loadingView = IS_DEVICE_PHONE ? [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)]: [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
        _loadingView.center = windowCenter;
        _loadingView.wonderLabel.text = [NSString stringWithFormat:@"Wonder帐号 %@", _username];
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
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingProcess:) name:@"showLoadingProcess" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // UIApplication notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showLoadingProcess" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    // UIApplication notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL);
    NSURL *url = request.URL;
    NSString *urlString = request.URL.absoluteString;

    if ([@[@"userLogin", @"normalRegister"] containsObject:url.lastPathComponent]) {
        WDURLParser *urlParser = [[WDURLParser alloc] initWithURLString:urlString];
        _username = [urlParser valueForVariable:@"username"];
        _password = [urlParser valueForVariable:@"password"];
    
        if (_username && _password) {
            _user = [[WonderUser alloc] initWithUsername:_username password:_password];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoadingProcess" object:nil userInfo:@{@"username" : _username}];
        }
    }
    
    if ([@[@"loginRedirect", @"tipsRedirect", @"registerRedirect"] containsObject:url.lastPathComponent]) {
//        __weak WonderLoginViewController *weakSelf = self;
        WDURLParser *urlParser = [[WDURLParser alloc] initWithURLString:urlString];
        NSString *value = [urlParser valueForVariable:@"command"];
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // login succeed
            if ([value isEqualToString:@"login_return_success"]) {
                if (_username && _password) {
                    [[WDUserStore sharedStore] addUser:_user]; // save user account
                }
                
                //TODO: game start
            }
            
            // login failed or register failed,
            // so you should return login screen
            if ([@[@"login_return_fail", @"register_return_fail"] containsObject:value]) {
                [self.view addSubview:_webView];
            }
            
            [_switchAccountButton removeFromSuperview];
            [_loadingView removeFromSuperview];
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
        NSString *jsUserName = [NSString stringWithFormat:@"document.getElementById('username').value = '%@'", [[WDUserStore sharedStore] lastUser].userName];
        NSString *jsPassWord = [NSString stringWithFormat:@"document.getElementById('password').value = '%@'", [[WDUserStore sharedStore] lastUser].passWord];
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
    if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        NSLog(@"\nerror.domain是%@", error.domain);
    }
    NSLog(@"error.code: %ld", (long)error.code);
}

#pragma mark - NSKeyValueObserving Protocol

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
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _kbRect = [self.view convertRect:keyboardFrame fromView:self.view.window];
    NSLog(@"%@", self.view.window);
    
    _webViewHeight = CGRectGetMinY(_webView.frame);

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
    [self wonderLogin];
}

// for ios 5 earlier
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        <#statements#>
//    }
//}

// for ios 6 later
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}

//- (BOOL)shouldAutorotate {
//    return YES;
//}
#pragma mark - Helper methods

- (CGSize)currentScreenSize {
    // iOS 8 simply adjusts the application frame to adapt to the current orientation and deprecated the concept of interface orientations
    if (!IS_OS_8_0_LATER) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGSize currentScrrenSize = CGSizeMake(CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
            return currentScrrenSize;
        }
    }
    
    return [UIScreen mainScreen].bounds.size;
}

@end


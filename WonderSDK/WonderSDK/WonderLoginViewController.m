//
//  WonderLoginViewController.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderLoginViewController.h"
#import "WonderURLParser.h"
#import "WonderUserStore.h"
#import "WonderUser.h"
#import "WonderLoadingView.h"

#import "WebViewJavascriptBridge.h"

#define isDevicePhone [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
#define windowCenter CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)

NSString * const baseURL = @"http://192.168.1.251:8008/jsp/";
//NSString * const baseURL = @"http://218.17.158.13:3337/wonderCenter/jsp/";

@interface WonderLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIButton *switchAccountButton;
@property (strong, nonatomic) WonderLoadingView *loadingView;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) WonderUser *user;

@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGRect kbRect;
@property (assign, nonatomic) CGFloat webViewHeight;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

@end

@implementation WonderLoginViewController

#pragma mark - UIViewController lifecycle

//- (void)viewDidLayoutSubviews {
//    NSLog(@"windowcenter:%@", NSStringFromCGPoint(windowCenter));
//    NSLog(@"View frame: %@", NSStringFromCGRect(self.view.bounds));
//    NSLog(@"av:%@", NSStringFromCGRect(_activityIndicatorView.frame));
//    NSLog(@"av:%@", NSStringFromCGPoint(_activityIndicatorView.center));
//
//    NSLog(@"wv:%@", NSStringFromCGRect(_webView.frame));
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    // webView setup
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 540)];
    if (isDevicePhone) {
        _webView.frame = CGRectMake(0, 0, 320, 240);
    }
    _webView.center = windowCenter;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleBottomMargin |
                                 UIViewAutoresizingFlexibleTopMargin);
//    _webView.scalesPageToFit = YES;
    _webView.layer.masksToBounds = YES;
    _webView.layer.cornerRadius = 10;
    _webView.layer.shadowColor = [UIColor blackColor].CGColor;
    _webView.layer.shadowOpacity = 0.5f; // 阴影不透明度
    _webView.layer.shadowOffset = CGSizeMake(0, 5); // 阴影偏移量
    _webView.layer.shadowRadius = 10.0f; // 阴影模糊半径
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.scrollEnabled = NO; // 禁用滚动
    _webView.scrollView.bounces = NO; // 禁用回弹
    [self.view addSubview:_webView];
    
    // activityIndicatorView setup
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.color = [UIColor blackColor];
    _activityIndicatorView.center = windowCenter;
    _activityIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                               UIViewAutoresizingFlexibleLeftMargin |
                                               UIViewAutoresizingFlexibleBottomMargin |
                                               UIViewAutoresizingFlexibleTopMargin);
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    
    
    
    // receive JS messages
    _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[WonderUserStore sharedStore] removeUser:data];
        } else if ([data isKindOfClass:[NSNumber class]]){
            self.textFieldHeight = [(NSNumber *)data intValue];
            NSLog(@"%d", self.textFieldHeight);
        }
        
    }];
    
    [self wonderLogin];
    //    [[[WonderUserStore sharedStore] allUsers] enumerateObjectsUsingBlock:^(WonderUser *obj, NSUInteger idx, BOOL *stop) {
    //        NSLog(@"%lu  %@", (unsigned long)idx, obj.userName);
    //    }];
    //
    //    NSLog(@"lastUser: %@", [[WonderUserStore sharedStore] lastUser].userName);
    
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
    if ([[WonderUserStore sharedStore] lastUser]) {
        [self wonderLoginWithOutUI];
    } else {
        [self wonderLoginWithUI];
    }
}

- (void)wonderLoginWithUI {
//    [_webView stopLoading];
    NSURL *url = [NSURL URLWithString:@"login.jsp" relativeToURL:[NSURL URLWithString:baseURL]];
//    NSURL *url = [NSURL URLWithString:@"http://218.17.158.13:19999/test.html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)wonderLoginWithOutUI {
//    [_webView stopLoading];
    [_webView removeFromSuperview];
    NSString *urlString  = [NSString stringWithFormat:@"http://192.168.1.251:8008/api/userLogin?username=%@&&password=%@",
                            [[WonderUserStore sharedStore] lastUser].userName, [[WonderUserStore sharedStore] lastUser].passWord];
    NSURL *url = [NSURL URLWithString:urlString];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Private method

- (void)switchAccount {
//    [_webView stopLoading];
    [self.view addSubview:_webView];
    [self.switchAccountButton removeFromSuperview];
    [self.loadingView removeFromSuperview];
    [self wonderLoginWithUI];
}

// handle loading process
- (void)showLoadingProcess:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"showLoadingProcess"]) {
        [_webView removeFromSuperview];
        
        // loadingView setup
        _loadingView = [[WonderLoadingView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
        _loadingView.center = windowCenter;
        _loadingView.wonderLabel.text = [NSString stringWithFormat:@"Wonder帐号 %@", _username];
        [self.view addSubview:_loadingView];
                
        // switchAccountButton setup
        _switchAccountButton = [UIButton buttonWithType:UIButtonTypeSystem]; // ios 7.0+
        _switchAccountButton.frame = CGRectMake(30, 30, 150, 60);
        _switchAccountButton.backgroundColor = [UIColor colorWithRed:0.278 green:0.519 blue:0.918 alpha:1.000];
        _switchAccountButton.layer.cornerRadius = 5;
        _switchAccountButton.tintColor = [UIColor whiteColor];
        _switchAccountButton.titleLabel.font = [UIFont systemFontOfSize:20];
        //    _switchAccountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        //    [_switchAccountButton sizeToFit];
        [_switchAccountButton setTitle:@"切换帐号" forState:UIControlStateNormal];
        [_switchAccountButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchAccountButton];
        
    }
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingProcess:) name:@"showLoadingProcess" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showLoadingProcess" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL);
    NSURL *url = request.URL;
    NSString *urlString = request.URL.absoluteString;

    if ([@[@"userLogin", @"normalRegister"] containsObject:url.lastPathComponent]) {
        WonderURLParser *urlParser = [[WonderURLParser alloc] initWithURLString:urlString];
        _username = [urlParser valueForVariable:@"username"];
        _password = [urlParser valueForVariable:@"password"];
    
        if (_username && _password) {
            _user = [[WonderUser alloc] initWithUsername:_username password:_password];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoadingProcess" object:nil userInfo:@{@"username" : _username}];
        }
    }
    
    if ([@[@"loginRedirect", @"tipsRedirect", @"registerRedirect"] containsObject:url.lastPathComponent]) {
//        __weak WonderLoginViewController *weakSelf = self;
        WonderURLParser *urlParser = [[WonderURLParser alloc] initWithURLString:urlString];
        NSString *value = [urlParser valueForVariable:@"command"];
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // login succeed
            if ([value isEqualToString:@"login_return_success"]) {
                if (_username && _password) {
                    [[WonderUserStore sharedStore] addUser:_user]; // save user account
                }
                
                [_switchAccountButton removeFromSuperview];
                [_loadingView removeFromSuperview];
                
                //TODO: game start
            }
            
            // login failed or register failed,
            // so you should return login screen
            if ([@[@"login_return_fail", @"register_return_fail"] containsObject:value]) {
                [_switchAccountButton removeFromSuperview];
                [_loadingView removeFromSuperview];
                [self.view addSubview:_webView];
            }
        });
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicatorView stopAnimating];
    NSString *lastPathComponent = _webView.request.URL.lastPathComponent;
    if ([lastPathComponent isEqualToString: @"login.jsp"]) {
        NSString *jsFunction = [NSString stringWithFormat:@"addBox(\"%@\")", [[WonderUserStore sharedStore] stringWithJsonData]];
        [_webView stringByEvaluatingJavaScriptFromString:jsFunction];
    }
    
    if ([lastPathComponent isEqualToString:@"bindEmail.jsp"]) {
        if ([[WonderUserStore sharedStore] lastUser]) {
        NSString *jsUserName = [NSString stringWithFormat:@"document.getElementById('username').value = '%@'", [[WonderUserStore sharedStore] lastUser].userName];
        NSString *jsPassWord = [NSString stringWithFormat:@"document.getElementById('password').value = '%@'", [[WonderUserStore sharedStore] lastUser].passWord];
        [_webView stringByEvaluatingJavaScriptFromString:jsUserName];
        [_webView stringByEvaluatingJavaScriptFromString:jsPassWord];
        }
    }
//    NSLog(@"%@", NSStringFromCGPoint(self.webView.frame.origin));
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_activityIndicatorView stopAnimating];
    // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
    // NSURLErrorCancelled == "Operation could not be completed", note NSURLErrorCancelled occurs when
    // the user clicks away before the page has completely loaded, if we find cases where we want this
    // to result in dialog failure (usually this just means quick-user), then we should add something
    // more robust here to account for differences in application needs
    if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        NSLog(@"\nerror.domain是%@", error.domain);
    }
    NSLog(@"%ld", (long)error.code);
}

#pragma mark - NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"textFieldHeight"]) {
        CGFloat distanceTextFieldToTop = CGRectGetMinY(_webView.frame) + self.textFieldHeight + 0;
        CGFloat offset = CGRectGetMinY(_kbRect) - distanceTextFieldToTop;
//        if ([[UIDevice currentDevice].systemVersion floatValue] < 7) {
//            offset = CGRectGetMinY(_kbRect) - self.textFieldHeight;
//        }

        NSLog(@"offset:%.2f", offset);
        
        CGPoint webViewCenter = _webView.center;
        webViewCenter.y +=  offset - 80;

        [UIView animateWithDuration:.25 animations:^{
            _webView.center = webViewCenter;
        }];
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    NSLog(@"keyboardDidChangeFrame");
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _webViewHeight = _webView.frame.origin.y;
    NSDictionary *info = [notification userInfo];
    _kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSLog(@"keyboardWillShow");
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    CGPoint webViewCenter = _webView.center;
    webViewCenter.y = CGRectGetHeight(self.view.frame) / 2.0f;
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));

    [UIView animateWithDuration:.25 animations:^{
        _webView.center = webViewCenter;
    }];

}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"keyboardDidHide");
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self wonderLogin];
}

#pragma mark - Helper methods



@end


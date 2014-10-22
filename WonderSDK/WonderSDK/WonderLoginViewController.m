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

#define isDevicePad [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad
#define isDevicePhone [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone

NSString * const baseURL = @"http://192.168.1.251:8008/jsp/";
//NSString * const baseURL = @"http://218.17.158.13:3337/wonderCenter/jsp/";

@interface WonderLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIButton *switchAccountButton;
@property (strong, nonatomic) WonderLoadingView *loadingView;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;
@property (strong, nonatomic) NSURLRequest *loginRequest;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) WonderUser *user;

@property (strong, nonatomic) NSLayoutConstraint *centerYConstraint;
@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGSize kbSize;
@property (assign, nonatomic) CGFloat webViewHeight;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

@end

@implementation WonderLoginViewController

#pragma mark - Custome Accesstors

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.color = [UIColor blackColor];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self.view addSubview:_activityIndicatorView];
        
        [self centerLayoutConstraintWithView:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UIButton *)switchAccountButton {
    if (!_switchAccountButton) {
        _switchAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _switchAccountButton.layer.cornerRadius = 5;
        _switchAccountButton.backgroundColor = [UIColor colorWithRed:0.278 green:0.519 blue:0.918 alpha:1.000];
        _switchAccountButton.tintColor = [UIColor whiteColor];
        _switchAccountButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _switchAccountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _switchAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_switchAccountButton sizeToFit];
        [_switchAccountButton setTitle:@"切换帐号" forState:UIControlStateNormal];
        [_switchAccountButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _switchAccountButton;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        for (UIView *subview in _webView.subviews) {
            subview.layer.cornerRadius = 10;
        }
        _webView.layer.cornerRadius = 10;
        _webView.layer.shadowColor = [UIColor blackColor].CGColor;
        _webView.layer.shadowOpacity = 0.3f; // 阴影不透明度
        _webView.layer.shadowOffset = CGSizeMake(0, 5); // 阴影偏移量
        _webView.layer.shadowRadius = 10.0f; // 阴影模糊半径
        _webView.scrollView.delegate = self;
        _webView.scrollView.scrollEnabled = NO; // 禁用滚动
        _webView.scrollView.bounces = NO; // 禁用回弹
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _webView;
}

- (WonderLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[WonderLoadingView alloc] init];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _loadingView;
}

#pragma mark - UIViewController

// 注册通知
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loading:) name:@"userIsLoading" object:nil];
    [self registerForKeyboardNotifications];
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];

    _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[WonderUserStore sharedStore] removeUser:data];
        } else if ([data isKindOfClass:[NSNumber class]]){
            self.textFieldHeight = [(NSNumber *)data intValue];
            NSLog(@"%d", self.textFieldHeight);
        }
        
    }];
    
//    [[[WonderUserStore sharedStore] allUsers] enumerateObjectsUsingBlock:^(WonderUser *obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%lu  %@", (unsigned long)idx, obj.userName);
//    }];
//
//    NSLog(@"lastUser: %@", [[WonderUserStore sharedStore] lastUser].userName);

}

// 注销通知
- (void)viewWillDisappear:(BOOL)animated {
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    [self unregisterForKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userIsLoading" object:nil];
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
    NSURL *url = [NSURL URLWithString:@"login.jsp" relativeToURL:[NSURL URLWithString:baseURL]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.webView];
    [self constraintWithDevice:[UIDevice currentDevice].userInterfaceIdiom];
}

- (void)wonderLoginWithOutUI {
    NSString *urlString  = [NSString stringWithFormat:@"http://218.17.158.13:3337/wonderCenter/api/userLogin?username=%@&&password=%@", [[WonderUserStore sharedStore] lastUser].userName, [[WonderUserStore sharedStore] lastUser].passWord];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)switchAccount {
    [self.switchAccountButton removeFromSuperview];
    [self.loadingView removeFromSuperview];
    
    [self wonderLoginWithUI];
}

- (void)loading:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"userIsLoading"]) {
        [self.webView removeFromSuperview];
        
        [self.view addSubview:self.switchAccountButton];
        
        // switchAccountButton constraints
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_switchAccountButton);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_switchAccountButton]-|" options:0 metrics:nil views:viewsDictionary];
        [self.view addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_switchAccountButton]" options:0 metrics:nil views:viewsDictionary];
        [self.view addConstraints:constraints];
        
        NSDictionary *userInfoDictionary = [notification userInfo];
        self.loadingView.wonderLabel.text = [NSString stringWithFormat:@"Wonder 帐号 %@", [userInfoDictionary valueForKey:@"username"]];
        [self.view addSubview:self.loadingView];
        
        // self.loadingView constraints
        viewsDictionary = NSDictionaryOfVariableBindings(_loadingView);
        if (isDevicePad) {
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_loadingView(500)]" options:0 metrics:nil views:viewsDictionary];
            [self.view addConstraints:constraints];
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_loadingView(200)]" options:0 metrics:nil views:viewsDictionary];
            [self.view addConstraints:constraints];
        } else if (isDevicePhone){
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_loadingView(300)]" options:0 metrics:nil views:viewsDictionary];
            [self.view addConstraints:constraints];
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_loadingView(200)]" options:0 metrics:nil views:viewsDictionary];
            [self.view addConstraints:constraints];
        }
        
        [self centerLayoutConstraintWithView:_loadingView];
    
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL);
    __block NSString *urlString = request.URL.absoluteString;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    if ([urlString rangeOfString:@"userLogin"].location != NSNotFound || [urlString rangeOfString:@"normalRegister"].location != NSNotFound) {
        WonderURLParser *urlParser = [[WonderURLParser alloc] initWithURLString:urlString];
        _username = [urlParser valueForVariable:@"username"];
        _password = [urlParser valueForVariable:@"password"];
    
        if (_username && _password) {
            _user = [[WonderUser alloc] initWithUsername:_username AndPassword:_password];
            [notificationCenter postNotificationName:@"userIsLoading" object:nil userInfo:@{@"username" : _username}];
        }
    }
    
    if ([urlString rangeOfString:@"loginRedirect"].location != NSNotFound ||
        [urlString rangeOfString:@"tipsRedirect"].location != NSNotFound ||
        [urlString rangeOfString:@"registerRedirect"].location != NSNotFound) {
        __weak WonderLoginViewController *weakSelf = self;
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // 登录成功
            if ([urlString rangeOfString:@"login_return_success"].location != NSNotFound) {
                if (_username && _password) {
                    [[WonderUserStore sharedStore] addUser:_user];
                }
                
                [self.switchAccountButton removeFromSuperview];
                [_loadingView removeFromSuperview];
            }
            
            // 登录失败
            if ([urlString rangeOfString:@"login_return_fail"].location != NSNotFound || [urlString rangeOfString:@"register_return_fail"].location != NSNotFound) {
                [self.switchAccountButton removeFromSuperview];
                [_loadingView removeFromSuperview];
                [self.view addSubview:self.webView];
                [weakSelf constraintWithDevice:[UIDevice currentDevice].userInterfaceIdiom];
            }
        });
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicatorView stopAnimating];
    NSString *lastPathComponent = self.webView.request.URL.lastPathComponent;
    if ([lastPathComponent isEqualToString: @"login.jsp"]) {
        NSString *jsFunction = [NSString stringWithFormat:@"addBox(\"%@\")", [[WonderUserStore sharedStore] stringWithJsonData]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsFunction];
    }
    
    if ([lastPathComponent isEqualToString:@"bindEmail.jsp"]) {
        if ([[WonderUserStore sharedStore] lastUser]) {
        NSString *jsUserName = [NSString stringWithFormat:@"document.getElementById('username').value = '%@'", [[WonderUserStore sharedStore] lastUser].userName];
        NSString *jsPassWord = [NSString stringWithFormat:@"document.getElementById('password').value = '%@'", [[WonderUserStore sharedStore] lastUser].passWord];
        [self.webView stringByEvaluatingJavaScriptFromString:jsUserName];
        [self.webView stringByEvaluatingJavaScriptFromString:jsPassWord];
        }
    }
//    NSLog(@"%@", NSStringFromCGPoint(self.webView.frame.origin));
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];

    NSLog(@"\nerror=%@", error);
}

#pragma mark - NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"textFieldHeight"]) {
        CGFloat distanceTextFieldToTop = _webViewHeight + self.textFieldHeight + 80;
        CGFloat offset = (([UIScreen mainScreen].bounds.size.height - distanceTextFieldToTop) - _kbSize.height);
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7) {
            offset = (([UIScreen mainScreen].bounds.size.width - distanceTextFieldToTop) - _kbSize.height);
        }

        NSLog(@"offset:%f  C:%f  A:%f  B:%f", offset, [UIScreen mainScreen].bounds.size.height, distanceTextFieldToTop, _kbSize.height);
        
        [self.view layoutIfNeeded];
        
        _centerYConstraint.constant = offset < 0 ? offset : -offset;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    NSLog(@"keyboardDidChangeFrame");
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _webViewHeight = self.webView.frame.origin.y;
    NSDictionary *info = [notification userInfo];
//    _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGFloat height = _kbSize.height;
//    if (_kbSize.height > _kbSize.width) {
//        _kbSize.height = _kbSize.width;
//    }
    
    CGRect aRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:nil];
    _kbSize = aRect.size;
    
    NSLog(@"keyboardWillShow");
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    _centerYConstraint.constant = 0;
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"keyboardWillBeHidden");
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

- (void)centerLayoutConstraintWithView:(UIView *)view {
    // view.center.x = self.view.center.x
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0f
                                                                   constant:0.0f];
    [self.view addConstraint:constraint];
    
    // view.center.y = self.view.center.y
    constraint = [NSLayoutConstraint constraintWithItem:view
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0f
                                               constant:0.0f];
    [self.view addConstraint:constraint];
}

- (void)constraintWithDevice:(UIUserInterfaceIdiom)deviceType {
    if (deviceType == UIUserInterfaceIdiomPad) {
        
        // self.webView.centerX = self.view.centerX
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0f
                                                   constant:0.0f];
        [self.view addConstraint:constraint];

        // self.webView.centerY = self.view.centerY
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0f
                                                   constant:0.0f];
        _centerYConstraint = constraint;
        
        [self.view addConstraint:constraint];
        
        // self.webView.width = 700
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1.0f
                                                   constant:700.0f];
        
        [self.webView addConstraint:constraint];
        
        // self.webView.height = 0.8 * self.webView.width
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.webView
                                                  attribute:NSLayoutAttributeWidth
                                                 multiplier:0.8f
                                                   constant:0];
        
        [self.webView addConstraint:constraint];
        
    } else if(deviceType == UIUserInterfaceIdiomPhone) {
        
        // self.webView.centerX = self.view.centerX
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
        [self.view addConstraint:constraint];
        
        // self.webView.centerY = self.view.centerY
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0f
                                                   constant:0.0f];
        _centerYConstraint = constraint;
        
        [self.view addConstraint:constraint];
        
        // self.webView.height = 0.8 * self.webView.width
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1.0f
                                                   constant:300.0f];
        
        [self.webView addConstraint:constraint];
        
        // self.webView.height = 0.8 * self.webView.width
        constraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.webView
                                                  attribute:NSLayoutAttributeWidth
                                                 multiplier:0.8f
                                                   constant:0];
        
        [self.webView addConstraint:constraint];
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

@end

//
//  WDDialog.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDDialog.h"
#import "WDURLParser.h"
#import "WDUserStore.h"
#import "WDLoadingView.h"
#import "WDConstants.h"
#import "UIView+WDGeometryLayout.h"

// Vendors
#import "WebViewJavascriptBridge.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const loginURL = @"http://192.168.1.251:8008/jsp/login.jsp";
NSString * const testServerURL = @"http://218.17.158.13:3337/wonderCenter/jsp/";

static CGFloat kTransitionDuration = 0.3;

// This function determines if we want to use the legacy view layout in effect for iPhone OS 2.0
// through iOS 7, where we, the developer, have to worry about device orientation when working with
// views outside of the window's root view controller and apply the correct rotation transform and/
// or swap a view's width and height values. If the application was linked with UIKit on iOS 7 or
// earlier or the application is running on iOS 7 or earlier then we need to use the legacy layout
// code. Otherwise if the application was linked with UIKit on iOS 8 or later and the application
// is running on iOS 8 or later, UIKit handles all the rotation complexity and the origin is always
// in the top-left and no rotation transform is necessary.
static BOOL WDUseLegacyLayout(void) {
    return (!WDUseLegacyLayout);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

@interface WDDialog () <UIWebViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURL *loadingURL;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) BOOL everShown;
@property (assign, nonatomic) BOOL isViewInvisible;
@property (assign, nonatomic) BOOL showingKeyboard;
// Ensures that UI elements behind the dialog are disabled.
@property(nonatomic, strong) UIView *modalBackgroundView;
// 登录中
@property (strong, nonatomic) WDLoadingView *loadingView;
@property (assign, nonatomic) BOOL isClickedSwitchButton;
// 自适应键盘
@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGRect kbRect;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@end

@implementation WDDialog

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _loadingURL = nil;
        _delegate = nil;
        _isClickedSwitchButton = NO;
        _everShown = NO;

        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;

        [self setupBackgroundImage];
        [self setupWebView];
        [self setupSpinner];
        [self setupJavascriptBridge];

        _modalBackgroundView = [[UIView alloc] init];
#if DEBUG
        [WebViewJavascriptBridge enableLogging];
#endif
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _webView.delegate = nil;
    _webView.scrollView.delegate = nil;

    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

#pragma mark - Public

- (void)show {
    [self load];
    
    if (!self.isViewInvisible) {
        [self showSpinner];
        [self showWebView];
    }
    
}

- (void)load {
    [self loadURL:loginURL];
}

- (void)loadURL:(NSString *)url {
    self.loadingURL = [self generateURL:url params:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.loadingURL];
    
    [self.webView loadRequest:request];
}

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated {
    if (success) {
        if ([self.delegate respondsToSelector:@selector(dialogDidComplete:)]) {
            [self.delegate dialogDidComplete:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dialogDidNotComplete:)]) {
            [self.delegate dialogDidNotComplete:self];
        }
    }
    
    [self dismiss:animated];
}

- (void)dismissWithError:(NSError *)error animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(dialog:didFailWithError:)]) {
        [self.delegate dialog:self didFailWithError:error];
    }
    
    [self dismiss:animated];
}

- (void)dialogWillAppear {
    
}

- (void)dialogWillDisappear {
    
}

- (void)dialogDidSucceed:(NSURL *)url {
    if ([WDUserStore sharedStore].currentUser) {
        [[WDUserStore sharedStore] addUser:[WDUserStore sharedStore].currentUser];
    }

    if ([self.delegate respondsToSelector:@selector(dialogCompleteWithUrl:)]) {
        [self.delegate dialogCompleteWithUrl:url];
    }

    [self dismissWithSuccess:YES animated:YES];
}

- (void)dialogDidCancel:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(dialogDidNotCompleteWithUrl:)]) {
        [self.delegate dialogDidNotCompleteWithUrl:url];
    }
    [self dismissWithSuccess:NO animated:YES];
}

#pragma mark - Private

- (CGAffineTransform)transformForOrientation {
    // iOS 8 simply adjusts the application frame to adapt to the current orientation and deprecated the concept of interface orientations
    if (WDUseLegacyLayout()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            return CGAffineTransformMakeRotation(M_PI * 1.5);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            return CGAffineTransformMakeRotation(M_PI/2);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            return CGAffineTransformMakeRotation(-M_PI);
        }
    }
    
    return CGAffineTransformIdentity;
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void)setupJavascriptBridge {
    /* 接收 JS 消息 */
    __weak WDDialog *weakSelf = self;
    self.javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[WDUserStore sharedStore] removeUser:data];
        } else if ([data isKindOfClass:[NSNumber class]]) {
            weakSelf.textFieldHeight = [(NSNumber *)data intValue];
        }
    }];
}

- (void)saveAccount {
    [[WDUserStore sharedStore] saveAccountChangesWithCompletionHandler:^(BOOL success) {
        NSLog(@"save succeed");
    }];
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    // UIApplication notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:@"UIApplicationWillTerminateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAccount) name:@"UIApplicationWillResignActiveNotification" object:nil];
}

- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
    // UIApplication notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationWillTerminateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationWillResignActiveNotification" object:nil];
}

- (void)verifyLoginWithUrl:(NSURL *)url {
    if ([@[@"userLogin", @"normalRegister"] containsObject:url.lastPathComponent]) {
        NSString *username = [WDURLParser getValueForParameter:@"username=" fromUrlString:url.absoluteString];
        NSString *password = [WDURLParser getValueForParameter:@"password=" fromUrlString:url.absoluteString];
        [[WDUserStore sharedStore] setCurrentUserWithUsername:username andPassword:password];
        if ([WDUserStore sharedStore].currentUser) {
            [self showLoading];
        }
    }
}

- (void)fillDialogForUrl:(NSURL *)url {
    NSString *lastPathComponent = url.lastPathComponent;
    if ([lastPathComponent isEqualToString: @"login.jsp"]) {
        NSString *jsFunction = [NSString stringWithFormat:@"addBox(\"%@\")", [[WDUserStore sharedStore] stringWithJsonData]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsFunction];
    }
    
    if ([lastPathComponent isEqualToString:@"bindEmail.jsp"]) {
        if ([[WDUserStore sharedStore] lastUser]) {
            NSString *jsUserName = [NSString stringWithFormat:@"document.getElementById('nmid').value = '%@'", [[WDUserStore sharedStore] lastUser].userName];
            NSString *jsPassWord = [NSString stringWithFormat:@"document.getElementById('pwdid').value = '%@'", [[WDUserStore sharedStore] lastUser].passWord];
            [self.webView stringByEvaluatingJavaScriptFromString:jsUserName];
            [self.webView stringByEvaluatingJavaScriptFromString:jsPassWord];
        }
    }
}

- (NSURL *)generateURL:(NSString *)baseURL params:(NSDictionary *)params {
    if (params) {
        NSMutableArray *pairs = [NSMutableArray array];
        for (NSString *key in params.keyEnumerator) {
            NSString *value = [params objectForKey:key];
            //            NSString *escaped_value = [FBUtility stringByURLEncodingString:value];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
        
        NSString *query = [pairs componentsJoinedByString:@"&"];
        NSString *url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

- (CGSize)currentScreenSize {
    // iOS 8 simply adjusts the application frame to adapt to the current orientation and deprecated the concept of interface orientations
    if (!IS_OS_8_OR_LATER) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGSize currentScreenSize = CGSizeMake(CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
            return currentScreenSize;
        }
    }
    
    return [UIScreen mainScreen].bounds.size;
}

- (void)dismiss:(BOOL)animated {
    [self dialogWillDisappear];
    
    self.loadingURL = nil;
    
    if (animated && self.everShown) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
        self.alpha = 0;
        [UIView commitAnimations];
    } else {
        [self postDismissCleanup];
    }
}

- (void)postDismissCleanup {
    [self.loadingView stopAnimating];
    [self removeObservers];
    [self.modalBackgroundView removeFromSuperview];
    [self removeFromSuperview];
    
    // this method call could cause a self-cleanup, and needs to really happen "last"
    // If the dialog has been closed, then we need to cancel the order to open it.
    // This happens in the case of a frictionless request, see webViewDidFinishLoad for details
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showWebView)
                                               object:nil];
}

#pragma mark - UIView

- (void)setupWebView {
    CGPoint center;
    if (WDUseLegacyLayout()) {
        center = CGPointMake(self.frameHeight / 2.0f, self.frameWidth / 2.0f);
    } else {
        center = CGPointMake(self.frameWidth / 2.0f, self.frameHeight / 2.0f);
    }
    
    /* webView 设置 */
    self.webView = IS_IPHONE ? [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] : [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 540)];
    self.webView.center = center;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    [self addSubview:self.webView];
}

- (void)setupBackgroundImage {
    CGFloat landscapeWidth;
    if (WDUseLegacyLayout()) {
        landscapeWidth = CGRectGetHeight([UIScreen mainScreen].bounds);
    } else {
        landscapeWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    UIImageView *background;
    if (landscapeWidth == 480) {
        // 3.5 inch
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_480w"]];
    } else if (landscapeWidth == 1024) {
        // iPad
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_1024w"]];
    } else {
        // default 4' screen
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoginBackground_568w"]];
    }
    [self addSubview:background];
}

- (void)setupSwitchButton {
    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeSystem]; // ios 7.0 later
    switchButton.frame = IS_IPHONE ? CGRectMake(15, 15, 100, 30) : CGRectMake(30, 30, 150, 60);
    switchButton.backgroundColor = [UIColor colorWithRed:0.278 green:0.519 blue:0.918 alpha:1.000];
    switchButton.layer.masksToBounds = YES;
    switchButton.layer.cornerRadius = 5;
    switchButton.tintColor = [UIColor whiteColor];
    switchButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [switchButton setTitle:@"切换帐号" forState:UIControlStateNormal];
    [switchButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchButton];
}

- (void)setupSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor blackColor];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.spinner];
}

- (void)showWebView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        for(window in [UIApplication sharedApplication].windows) {
            if (window.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    self.modalBackgroundView.frame = window.frame;
    [self.modalBackgroundView addSubview:self];
    [window addSubview:self.modalBackgroundView];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    self.everShown = YES;
    [self dialogWillAppear];
    [self addObservers];
}

// Show a spinner during the loading time for the dialog. This is designed to show
// on top of the webview but before the contents have loaded.
- (void)showSpinner {
    [self.spinner sizeToFit];
    [self.spinner startAnimating];
    self.spinner.center = self.webView.center;
}

- (void)hideSpinner {
    [self.spinner stopAnimating];
}

- (void)showLoading {
    CGPoint frameCenter = IS_OS_8_OR_LATER ? CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)
    : CGPointMake(self.frame.size.height / 2.0f, self.frame.size.width / 2.0f);
    // loadingView setup
    self.loadingView = IS_IPHONE ? [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)]: [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    self.loadingView.center = frameCenter;
    [self addSubview:self.loadingView];
    
    [self setupSwitchButton];
}

- (void)switchAccount {
    self.isClickedSwitchButton = YES;
    [self.loadingView removeFromSuperview];
    [self addSubview:self.webView];
    //    [self wonderLoginWithUI];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL);
    NSURL *url = request.URL;

    [self verifyLoginWithUrl:url];

    // 登录、注册返回的结果
    if ([@[@"loginRedirect", @"tipsRedirect", @"registerRedirect"] containsObject:url.lastPathComponent]) {
        __weak WDDialog *weakSelf = self;
        NSString *command = [WDURLParser getValueForParameter:@"command=" fromUrlString:url.absoluteString];
        // 延时 2 秒
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            if ([command isEqualToString:@"login_return_success"] && !weakSelf.isClickedSwitchButton) {
                //TODO: 登录成功
                [weakSelf dialogDidSucceed:url];
            } else if ([command isEqualToString:@"login_return_fail"]){
                //TODO: 登录失败
                NSString *errorCode = [WDURLParser getValueForParameter:@"code=" fromUrlString:url.absoluteString];
                NSString *errorString = [WDURLParser getValueForParameter:@"msg=" fromUrlString:url.absoluteString];
                if (errorCode) {
                    NSDictionary *errorData = [NSDictionary dictionaryWithObject:errorString forKey:@"error_msg"];
                    NSError *error = [NSError errorWithDomain:@"wondersdkErrorDomain"
                                                         code:[errorCode intValue]
                                                     userInfo:errorData];
                    [weakSelf dismissWithError:error animated:YES];
            } else {
                    [self dialogDidCancel:url];
                }
        }
        });
    }
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.isViewInvisible) {
        // if our cache asks us to hide the view, then we do, but
        // in case of a stale cache, we will display the view in a moment
        // note that showing the view now would cause a visible white
        // flash in the common case where the cache is up to date
        [self performSelector:@selector(showWebView) withObject:nil afterDelay:.05];
        [self fillDialogForUrl:webView.request.URL];
    } else {
        [self hideSpinner];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
    // NSURLErrorCancelled == "Operation could not be completed", note NSURLErrorCancelled occurs when
    // the user clicks away before the page has completely loaded, if we find cases where we want this
    // to result in dialog failure (usually this just means quick-user), then we should add something
    // more robust here to account for differences in application needs
    if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        [self dismissWithError:error animated:YES];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"textFieldHeight"]) {
        CGFloat distanceTextFieldToTop = CGRectGetMinY(self.webView.frame) + self.textFieldHeight + 30;
        CGFloat offset = ([self currentScreenSize].height - CGRectGetHeight(_kbRect)) - distanceTextFieldToTop;
        NSLog(@"offset:%f", offset);
        CGPoint webViewCenter = self.webView.center;
        webViewCenter.y +=  offset - 40;
        
        [UIView animateWithDuration:.25 animations:^{
            self.webView.center = webViewCenter;
        }];
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification *)notification {
    self.showingKeyboard = YES;

    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _kbRect = [self convertRect:keyboardFrame fromView:self.window];
//    CGRectGetMinY(self.webView.frame);
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.showingKeyboard = NO;

    CGPoint webViewCenter = self.webView.center;
    webViewCenter.y = [self currentScreenSize].height / 2.0f;
    
    [UIView animateWithDuration:.25 animations:^{
        self.webView.center = webViewCenter;
    }];
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"The %@ button was tapped.", [theAlert buttonTitleAtIndex:buttonIndex]);
//    [self startLogin];
}

@end


//
//  WDDialog.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDDialog.h"

#import "WDUserStore.h"
#import "WDLoadingView.h"
#import "WDConstants.h"
// Vendors
#import "WebViewJavascriptBridge.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kTransitionDuration = 0.3;

// 此函数决定是否我们想要为了 iPhone OS 2.0 到 iOS 7 系统而使用传统的视图布局方式，当处理窗口根视图外部的视图时，
// 开发者必须考虑设备方向并应用正确的旋转转换并交换视图宽高的值。如果应用运行在 iOS 7 上或之前的系统，那么我们需要
// 使用传统布局代码。否则如果应用运行在 iOS 8 或之后的系统，UIKit 会处理所有复杂的旋转并且原点总是处于左上并且不需要
// 设置旋转变换。
static BOOL WDUseLegacyLayout(void) {
    return (!IS_OS_8_OR_LATER);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

@interface WDDialog () <UIAlertViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) BOOL everShown;
@property (assign, nonatomic) BOOL isViewInvisible;
@property (assign, nonatomic) UIInterfaceOrientation orientation;
// 登录过程
@property (strong, nonatomic) WDLoadingView *loadingView;
@property (strong, nonatomic) UIButton *switchButton;
@property (assign, nonatomic) BOOL isClickedSwitchButton;
// 自适应键盘
@property (assign, nonatomic) int textFieldHeight;
@property (assign, nonatomic) CGRect kbRect;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@end

@implementation WDDialog

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
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
        
#if DEBUG
        [WebViewJavascriptBridge enableLogging];
#endif
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _webView.scrollView.delegate = nil;

    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

#pragma mark - Public

- (instancetype)initWithURL:(NSString *)serverURL params:(NSMutableDictionary *)params isViewInvisible:(BOOL)isViewInvisible delegate:(id<WDDialogDelegate>)delegate {
    self = [self init];
    _serverURL = serverURL;
    _params = params;
    _delegate = delegate;
    _isViewInvisible = isViewInvisible;

    return self;
}

- (NSString *)getValueForParameter:(NSString *)Param fromUrlString:(NSString *)urlString {
    NSString *value;
    NSRange start = [urlString rangeOfString:Param];
    if (start.location != NSNotFound) {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0) {
            c = [urlString characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#') {
            NSRange end = [[urlString substringFromIndex:start.location + start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location + start.length;
            value = end.location == NSNotFound ?
            [urlString substringFromIndex:offset] :
            [urlString substringWithRange:NSMakeRange(offset, end.location)];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return value;
}

- (void)show {
    [self load];
    [self sizeToFitOrientation:YES];
    [self showSpinner];
    [self showView];
}

- (void)load {
    [self loadURL:self.serverURL get:self.params];
}

- (void)loadURL:(NSString *)url get:(NSDictionary *)getParams {
    self.loadingURL = [self generateURL:url params:getParams];
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
    [self saveAccount];
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

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight;
}

- (void)sizeToFitOrientation:(BOOL)transform {
    if (transform) {
        self.transform = CGAffineTransformIdentity;
    }

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = floor(screenBounds.size.width);
    CGFloat screenHeight = floor(screenBounds.size.height);
    CGPoint ScreenCenter = CGPointMake(ceil(screenWidth/2), ceil(screenHeight/2));
    
    if (WDUseLegacyLayout()) {
        self.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    } else {
        self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }
    self.center = ScreenCenter;
    self.webView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    if (transform) {
        self.transform = [self transformForOrientation];
    }
    
}

- (CGAffineTransform)transformForOrientation {
    // iOS 8 直接改变 application frame 来适应当前方向，并且弃用了 interface orientations.
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (WDUseLegacyLayout()) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            return CGAffineTransformMakeRotation(-M_PI/2.0f);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            return CGAffineTransformMakeRotation(M_PI/2.0f);
        }
    }
    
    return CGAffineTransformIdentity;
}

- (void)updateWebOrientation {
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        [_webView stringByEvaluatingJavaScriptFromString:
//         @"document.body.setAttribute('orientation', 90);"];
//    } else {
//        [_webView stringByEvaluatingJavaScriptFromString:
//         @"document.body.removeAttribute('orientation');"];
//    }
}

- (void)setupJavascriptBridge {
    /* 接收 JS 消息 */
    self.javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSString class]]) {
            [[WDUserStore sharedStore] removeUser:data];
            [[WDUserStore sharedStore] saveAccountChangesWithCompletionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"delete succeed");
                }
            }];
        } else if ([data isKindOfClass:[NSNumber class]]) {
            self.textFieldHeight = [(NSNumber *)data intValue];
        }
    }];
}

- (void)saveAccount {
    [[WDUserStore sharedStore] addUser:[WDUserStore sharedStore].currentUser];
    [[WDUserStore sharedStore] saveAccountChangesWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"save succeed");
        }
    }];
}

- (void)switchAccount {
    self.isClickedSwitchButton = YES;
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
    
    [self loadURL:@"http://192.168.1.251:8008/jsp/login.jsp" get:nil];
    [self addSubview:self.webView];
    [self.switchButton removeFromSuperview];
}

- (void)addObservers {
    [self addObserver:self forKeyPath:@"textFieldHeight" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIApplicationDidChangeStatusBarOrientationNotification" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification" object:nil];
}

- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"textFieldHeight"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIApplicationDidChangeStatusBarOrientationNotification" object:nil];
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
}

- (void)verifyLoginWithUrl:(NSURL *)url {
    if ([@[@"userLogin", @"normalRegister"] containsObject:url.lastPathComponent]) {
        NSString *username = [self getValueForParameter:@"username=" fromUrlString:url.absoluteString];
        NSString *password = [self getValueForParameter:@"password=" fromUrlString:url.absoluteString];
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
            NSString *value = params[key];
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
            return CGSizeMake(CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
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
    [self.switchButton removeFromSuperview];
    [self removeFromSuperview];
    [self removeObservers];
    
    // this method call could cause a self-cleanup, and needs to really happen "last"
    // If the dialog has been closed, then we need to cancel the order to open it.
    // This happens in the case of a frictionless request, see webViewDidFinishLoad for details
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showView)
                                               object:nil];
}

#pragma mark - UIView

- (void)setupWebView {
    /* webView 设置 */
    self.webView = IS_IPHONE ? [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] : [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 540)];
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    [self addSubview:self.webView];
}

- (void)setupBackgroundImage {
    CGFloat landscapeWidth = WDUseLegacyLayout() ? CGRectGetHeight([UIScreen mainScreen].bounds) : CGRectGetWidth([UIScreen mainScreen].bounds);
    
    UIImageView *backgroundImageView;
    if (landscapeWidth == 480) {
        // 3.5 inch
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WDDialogResources.bundle/WDLoginBackground_480w"]];
        // default 4' screen
    } else if (landscapeWidth == 1024) {
        // iPad
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WDDialogResources.bundle/WDLoginBackground_1024w"]];
    } else {
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WDDialogResources.bundle/WDLoginBackground_568w"]];
    }
    [self addSubview:backgroundImageView];
}

- (void)setupSwitchButton {
    self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem]; // ios 7.0 later
    self.switchButton.frame = IS_IPHONE ? CGRectMake(15, 15, 100, 30) : CGRectMake(30, 30, 150, 60);
    self.switchButton.backgroundColor = [UIColor colorWithRed:0.278 green:0.519 blue:0.918 alpha:1.000];
    self.switchButton.layer.masksToBounds = YES;
    self.switchButton.layer.cornerRadius = 5;
    self.switchButton.tintColor = [UIColor whiteColor];
    self.switchButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.switchButton setTitle:@"切换帐号" forState:UIControlStateNormal];
    [self.switchButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.switchButton];
}

- (void)setupSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor blackColor];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                    | UIViewAutoresizingFlexibleBottomMargin
                                    | UIViewAutoresizingFlexibleLeftMargin
                                    | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.spinner];
}

// pop-up 显示 dialog
- (void)showView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        for(window in [UIApplication sharedApplication].windows) {
            if (window.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    [window addSubview:self];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    if (self.isViewInvisible) {
        [self.webView removeFromSuperview];
    }
    self.everShown = YES;
    [self dialogWillAppear];
    [self addObservers];
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
//    self.webView.hidden = YES;
    [self.webView removeFromSuperview];
    CGPoint frameCenter = IS_OS_8_OR_LATER ? CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)
    : CGPointMake(self.frame.size.height / 2.0f, self.frame.size.width / 2.0f);
    // loadingView setup
    self.loadingView = IS_IPHONE ? [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)]: [[WDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    self.loadingView.center = frameCenter;
    [self addSubview:self.loadingView];
    
    if (self.switchButton && !self.switchButton.superview) {
        [self addSubview:self.switchButton];
    } else {
        [self setupSwitchButton];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;

    [self verifyLoginWithUrl:url];

    // 登录、注册返回的结果
    if ([@[@"loginRedirect", @"tipsRedirect", @"registerRedirect"] containsObject:url.lastPathComponent]) {
        NSString *command = [self getValueForParameter:@"command=" fromUrlString:url.absoluteString];
        // 延时 2 秒
        double delayInSeconds = 2.0;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            if ([command isEqualToString:@"login_return_success"] && !self.isClickedSwitchButton) {
                //TODO: 登录成功
                [self dialogDidSucceed:url];
            } else if ([command isEqualToString:@"login_return_fail"]){
                //TODO: 登录失败
                NSString *errorCode = [self getValueForParameter:@"code=" fromUrlString:url.absoluteString];
                NSString *errorString = [self getValueForParameter:@"msg=" fromUrlString:url.absoluteString];
                if (errorCode) {
                    NSDictionary *errorData = @{@"errorMessage" : errorString};
                    NSError *error = [NSError errorWithDomain:@"WonderSdkErrorDomain"
                                                         code:[errorCode intValue]
                                                     userInfo:errorData];
                    [self dismissWithError:error animated:YES];
                } else {
                    [self dialogDidCancel:url];
                }
            }
            self.isClickedSwitchButton = NO;
            [self.loadingView stopAnimating];
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
//        [self performSelector:@selector(showWebView) withObject:nil afterDelay:.05];
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
//    self.showingKeyboard = YES;

    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _kbRect = [self convertRect:keyboardFrame fromView:self.window];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
//    self.showingKeyboard = NO;

    CGPoint webViewCenter = self.webView.center;
    webViewCenter.y = [self currentScreenSize].height / 2.0f;
    
    [UIView animateWithDuration:.25 animations:^{
        self.webView.center = webViewCenter;
    }];
    
}

#pragma mark - UIApplicationDidChangeStatusBarOrientationNotification

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([self shouldRotateToOrientation:orientation]) {
        [self updateWebOrientation];
        
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView animateWithDuration:duration animations:^{
            [self sizeToFitOrientation:YES];
        }];
    }
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


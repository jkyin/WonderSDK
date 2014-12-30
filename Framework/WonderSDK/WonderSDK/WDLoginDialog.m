//
//  WDLoginDialog.m
//  WonderSDK
//
//  Created by Wonder on 14/12/24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDLoginDialog.h"

#import "WDDialog.h"
#import "WDUserStore.h"
#import "WDUtility.h"

@implementation WDLoginDialog

/*
 * initialize the WDLoginDialog with url and parameters
 */
- (instancetype)initWithURL:(NSString *)loginURL loginParams:(NSMutableDictionary *)params delegate:(id<WDLoginDialogDelegate>)loginDelegate {
    if ((self = [super init])) {
        _serverURL = loginURL;
        _params = params;
        _loginDelegate = loginDelegate;
    }
    return self;
}

- (void)dealloc {
    
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

#pragma mark - WDDialog

/**
 * Override WDDialog : to call when the webView Dialog did succeed
 */
- (void)dialogDidSucceed:(NSURL *)url {
    [self saveAccount];
    
    NSString *urlString = url.absoluteString;
    NSString *token = [self getValueForParameter:@"token=" fromUrlString:urlString];

    if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
        [self dialogDidCancel:url];
        [self dismissWithSuccess:NO animated:YES];
    } else {
        NSDictionary *params = [WDUtility queryParamsDictionaryFromWDURL:url];
        if ([self.loginDelegate respondsToSelector:@selector(WDDialogLogin:params:)]) {
            [self.loginDelegate WDDialogLogin:token params:params];
        }
        [self dismissWithSuccess:YES animated:YES];
    }
    
}

/**
 * Override WDDialog : to call with the login dialog get canceled
 */
- (void)dialogDidCancel:(NSURL *)url {
    [self dismissWithSuccess:NO animated:YES];
    if ([self.loginDelegate respondsToSelector:@selector(WDDialogNotLogin:)]) {
        [self.loginDelegate WDDialogNotLogin:YES];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        [super webView:webView didFailLoadWithError:error];
        if ([self.loginDelegate respondsToSelector:@selector(WDDialogNotLogin:)]) {
            [self.loginDelegate WDDialogNotLogin:NO];
        }
    }
}

@end

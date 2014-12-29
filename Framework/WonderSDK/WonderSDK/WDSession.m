//
//  WDSession.m
//  WonderSDK
//
//  Created by Wonder on 14/12/22.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDSession.h"

#import "WDUserStore.h"
#import "WDLoginDialog.h"

#define WD_BASE_URL @"http://192.168.1.251:8008/jsp/"

static NSString *kLogin = @"login";

@interface WDSession () <WDLoginDialogDelegate, WDDialogDelegate>
@property (strong, nonatomic) WDDialog *wdDialog;
@property (copy, nonatomic) WDSessionCompleteHandler loginHandler;
@end

@implementation WDSession

- (void)dealloc {
    _loginHandler = nil;
    _wdDialog.delegate = nil;
    
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

#pragma mark - Public

- (void)openWithCompletionHandler:(WDSessionCompleteHandler)handler {
    NSString *dialogURL;
    if ([[WDUserStore sharedStore] lastUser]) {
        //TODO:自动登录
    } else {
        //TODO:正常登录
        dialogURL = [WD_BASE_URL stringByAppendingFormat:@"%@.jsp", kLogin];
//        self.wdDialog = [[WDDialog alloc] initWithURL:dialogURL params:nil isViewInvisible:NO delegate:self];
        NSMutableDictionary *params;
        self.wdDialog = [[WDDialog alloc] initWithURL:dialogURL params:params isViewInvisible:NO delegate:self];
    }

    [self.wdDialog show];
    if (handler) {
       self.loginHandler = handler;
    }
}

#pragma mark - WDDialogDelegate

- (void)WDDialogLogin:(NSString *)token params:(NSDictionary *)params {
    NSError *error;
    self.token = token;
    self.loginHandler(self, error);
}

- (void)WDDialogNotLogin:(BOOL)cancelled {
    
}

#pragma mark - WDDialogDelegate

- (void)dialog:(WDDialog *)dialog didFailWithError:(NSError *)error {
    self.loginHandler(self, error);
}

@end

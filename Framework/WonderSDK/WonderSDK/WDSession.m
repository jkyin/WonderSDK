//
//  WDSession.m
//  WonderSDK
//
//  Created by Wonder on 14/12/22.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDSession.h"

#import "WDUserStore.h"
#import "WDDialog.h"

static NSString const *baseURL = @"http://192.168.1.251:8008/jsp/";
static NSString const *autoLoginURL = @"http://192.168.1.251:8008/api/";

static NSString *kLogin = @"login";
static NSString *kUserLogin = @"userLogin";

@interface WDSession () <WDDialogDelegate>
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
    if (handler) {
        // Note blocks are not value comparable, so this can intentionally result in false positives; nonetheless, let's
        // log it for easier identification/reporting in case developers do run into this edge case unexpectedly.
        NSString *dialogURL;
        WDUser *lastUser = [[WDUserStore sharedStore] lastUser];
        if (lastUser) {
            dialogURL = [autoLoginURL stringByAppendingFormat:@"%@", kUserLogin];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:lastUser.passWord forKey:@"password"];
            [params setObject:lastUser.userName forKey:@"username"];
            self.wdDialog = [[WDDialog alloc] initWithURL:dialogURL params:params isViewInvisible:YES delegate:self];
        } else {
            dialogURL = [baseURL stringByAppendingFormat:@"%@.jsp", kLogin];
            self.wdDialog = [[WDDialog alloc] initWithURL:dialogURL params:nil isViewInvisible:NO delegate:self];
        }

        [self.wdDialog show];
        if (handler) {
           self.loginHandler = handler;
        }
    }
}

#pragma mark - WDDialogDelegate

- (void)dialogCompleteWithUrl:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSString *token = [self.wdDialog getValueForParameter:@"token=" fromUrlString:urlString];
    
    if ((token == (NSString *)[NSNull null]) || (token.length == 0)) {
        [self.wdDialog dialogDidCancel:url];
    } else {
        self.token = token;
        self.loginHandler(self, nil);
    }
}

- (void)dialog:(WDDialog *)dialog didFailWithError:(NSError *)error {
    self.loginHandler(nil, error);
}

@end

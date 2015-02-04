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
#import "WDUtility.h"

@interface WDSession () <WDDialogDelegate>
@property (nonatomic, strong) WDDialog *dialog;
@property (nonatomic, copy) WDSessionCompleteHandler loginHandler;
@property (nonatomic, copy, readwrite) NSString *token;
@property (nonatomic, copy, readwrite) NSString *username;
@end

@implementation WDSession

- (void)dealloc {
    _loginHandler = nil;
    _dialog.delegate = nil;
    
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

- (NSString *)username {
    return [WDUserStore sharedStore].currentUser.username;
}

#pragma mark - Public

- (void)openWithCompletionHandler:(WDSessionCompleteHandler)handler {
    if (handler) {
        NSString *dialogURL;
        WDUser *lastUser = [[WDUserStore sharedStore] lastUser];
        if (lastUser) {
            dialogURL = [WDUtility dialogUserLoginURL];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            params[@"password"] = lastUser.password;
            params[@"username"] = lastUser.username;
            
            self.dialog = [[WDDialog alloc] initWithURL:dialogURL params:params isViewInvisible:YES delegate:self];
        } else {
            dialogURL = [WDUtility dialogLoginURL];
            self.dialog = [[WDDialog alloc] initWithURL:dialogURL params:nil isViewInvisible:NO delegate:self];
        }

        [self.dialog show];
        self.loginHandler = handler;
    }
}

#pragma mark - WDDialogDelegate

- (void)dialogCompleteWithUrl:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSString *token = [self.dialog valueForParameter:@"token=" fromURLString:urlString];
    
    if ((token == (NSString *)[NSNull null]) || (token.length == 0)) {
        [self.dialog dialogDidCancel:url];
    } else {
        WDSession * __weak weakSelf = self;
        self.token = token;
        self.loginHandler(weakSelf, nil);
    }
}

- (void)dialog:(WDDialog *)dialog didFailWithError:(NSError *)error {
    self.loginHandler(nil, error);
}

@end

#if !__has_feature(objc_arc)
#error WonderSDK is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

//
//  WonderViewController.m
//  WonderSDKSample
//
//  Created by Wonder on 14/12/19.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderViewController.h"

#import <WonderSDK/WonderSDK.h>

@interface WonderViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) WDSession *session;
@end

@implementation WonderViewController

- (void)dealloc {
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginButton];
}

- (IBAction)gameLogin:(UIButton *)sender {
    self.session = [[WDSession alloc] init];
    [self.session openWithCompletionHandler:^(WDSession *session, NSError *error) {
        NSLog(@"session.token:%@  error:%@", session.token, error);
    }];

}

@end

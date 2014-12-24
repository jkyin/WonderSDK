//
//  WonderViewController.m
//  WonderSDKSample
//
//  Created by Wonder on 14/12/19.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderViewController.h"
#import <WonderSDK/WonderSDK.h>

@interface WonderViewController () <WDDialogDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) WDDialog *loginView;
@end

@implementation WonderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginButton];
    
    
}

- (IBAction)gameLogin:(UIButton *)sender {
    self.loginView = [[WDDialog alloc] initWithFrame:self.view.frame];
    self.loginView.delegate = self;
    [self.loginView show];

}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    NSLog(@"Token:%@", url);
}

- (void)dialogDidComplete:(WDDialog *)dialog {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end

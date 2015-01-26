//
//  ViewController.m
//  sample
//
//  Created by Jack Yin on 15/1/19.
//  Copyright (c) 2015年 Jack Yin. All rights reserved.
//

#import "ViewController.h"
#import <WonderSDK/WonderSDK.h>

@interface ViewController ()
@property (strong, nonatomic) WDSession *wdSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Login:(id)sender {
    self.wdSession = [[WDSession alloc] init];
    [self.wdSession openWithCompletionHandler:^(WDSession *session, NSError *error) {
        NSLog(@"token:%@ username: %@ error:%@", session.token, session.username, error.userInfo[@"errorMessage"]);
    }];
}

@end

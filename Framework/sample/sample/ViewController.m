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
@property (strong, nonatomic) WDSession *session;

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
    self.session = [[WDSession alloc] init];
    [self.session openWithCompletionHandler:^(WDSession *m, NSError *error) {
        NSLog(@"token:%@  error:%@", m.token, error.userInfo[@"errorMessage"]);
    }];
}
@end

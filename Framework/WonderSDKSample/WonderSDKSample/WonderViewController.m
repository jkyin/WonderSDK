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
@property (nonatomic,strong) MKMapView * myMapView;
@end

@implementation WonderViewController

- (void)dealloc {
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginButton];
    
//    // Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.myMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
//    self.myMapView.mapType = MKMapTypeHybrid;
//    self.myMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.myMapView.delegate = self;
//    //显示当前位置
//    self.myMapView.showsUserLocation = YES;
//    
//    [self.view addSubview:self.myMapView];
}

- (IBAction)gameLogin:(UIButton *)sender {
    self.session = [[WDSession alloc] init];
    [self.session openWithCompletionHandler:^(WDSession *m, NSError *error) {
        NSLog(@"token:%@  error:%@", m.token, error.userInfo[@"errorMessage"]);
    }];
}

@end

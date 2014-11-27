//
//  WonderAppDelegate.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation WonderAppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSLog(@"%d", __IPHONE_OS_VERSION_MIN_REQUIRED);
    [self.window setRootViewController:[WDLoginViewController sharedInstance]];
    [WDLoginViewController sharedInstance].delegate = self;
    [[WDLoginViewController sharedInstance] showLogin];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

- (void)dialogDidSucceedWithToken:(NSString *)token {
    NSLog(@"token: %@", token);
}

@end

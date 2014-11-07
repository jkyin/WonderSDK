//
//  WonderAppDelegate.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderAppDelegate.h"
#import <WonderSDK/WonderSDK.h>

@implementation WonderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window setRootViewController:[WDLoginViewController sharedInstance]];
    
    [[WDLoginViewController sharedInstance] showLogin];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

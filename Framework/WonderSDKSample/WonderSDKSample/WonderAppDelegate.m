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
#import "FLEXManager.h"

@interface WonderAppDelegate () <WDLoginViewControllerDelegate>

@end

@implementation WonderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[FLEXManager sharedManager] showExplorer];
    
    WDLoginViewController *loginViewController = [[WDLoginViewController alloc] init];
    loginViewController.delegate = self;
    [loginViewController showLogin];
    
    [self.window setRootViewController:loginViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

- (void)dialogDidSucceedWithToken:(NSString *)token {
    NSLog(@"token: %@", token);

}

@end

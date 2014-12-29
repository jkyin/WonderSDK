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
#import "WonderViewController.h"

@interface WonderAppDelegate ()

@end

@implementation WonderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    
    [self.window setRootViewController:vc];
    self.window.backgroundColor = [UIColor greenColor];
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

@end

//
//  WonderAppDelegate.m
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderAppDelegate.h"
#import "WonderLoginViewController.h"
#import "WonderUserStore.h"

@implementation WonderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    WonderLoginViewController *loginViewController = [[WonderLoginViewController alloc] init];
    [self.window setRootViewController:loginViewController];
        
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[WonderUserStore sharedStore] saveChanges];
    
    if (success) {
        NSLog(@"Saved");
    } else {
        NSLog(@"Cannot saved");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    BOOL success = [[WonderUserStore sharedStore] saveChanges];
    
    if (success) {
        NSLog(@"Saved");
    } else {
        NSLog(@"Cannot saved");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    BOOL success = [[WonderUserStore sharedStore] saveChanges];
    
    if (success) {
        NSLog(@"Saved");
    } else {
        NSLog(@"Cannot saved");
    }
}

@end

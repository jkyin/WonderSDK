//
//  WonderLoginViewController.h
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol WDLoginViewControllerDelegate

/**
 *  The delegate method, Successfully getting the token.
 */
- (void)dialogDidSucceedWithToken:(NSString *)token;

@end

@interface WDLoginViewController : UIViewController

/**
 *  The delegate.
 */
@property (nonatomic, weak) id<WDLoginViewControllerDelegate> delegate;

/**
 *  The method for loginning game.
 */
- (void)showLogin;

@end

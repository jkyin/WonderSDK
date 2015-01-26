//
//  WDDialog.h
//  WonderSDK
//
//  Created by Wonder on 14-8-11.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WDDialogDelegate;

@interface WDDialog : UIView <UIWebViewDelegate> {
    NSString *_serverURL;
    NSMutableDictionary *_params;
}

@property (strong, nonatomic) NSString *serverURL;
@property (strong, nonatomic) NSURL *loadingURL;
@property (strong, nonatomic) NSMutableDictionary *params;

/**
 * The delegate.
 */
@property (nonatomic, weak) id<WDDialogDelegate> delegate;

- (NSString *)getValueForParameter:(NSString *)Param fromUrlString:(NSString *)urlString;

- (void)saveAccount;

- (instancetype)initWithURL:(NSString *)serverURL
                     params:(NSMutableDictionary *)params
            isViewInvisible:(BOOL)isViewInvisible
                   delegate:(id<WDDialogDelegate>)delegate;

/**
* 显示视图。
*
* 这个视图会加入当前的 key window。
*/
- (void)show;

/**
* 显示对话框的第一个页面。
*/
- (void)load;

/**
* 加载带参数的 URL。
*/
- (void)loadURL:(NSString *)url get:(NSDictionary *)getParams;

/**
* 隐藏视图并通知成功或取消委托。
*/
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

/**
* 隐藏视图并通知错误委托。
*/
- (void)dismissWithError:(NSError *)error animated:(BOOL)animated;

/**
* 视图将要出现。
*/
- (void)dialogWillAppear;

/**
* 视图将要隐藏。
*/
- (void)dialogWillDisappear;

/**
* 处理从 URL 返回的数据。
*
* 实现必须调用 dismissWithSuccess:YES 方法来在某一时刻隐藏视图。
*/
- (void)dialogDidSucceed:(NSURL *)url;

/**
* 处理从 URL 返回的数据。
*
* 实现必须调用 dismissWithSuccess:YES 方法来在某一时刻隐藏视图。
*/
- (void)dialogDidCancel:(NSURL *)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol WDDialogDelegate <NSObject>

@optional

/**
 * 当对话已成功并且即将小时的时候被调用。
 */
- (void)dialogDidComplete:(WDDialog *)dialog;

/**
 * 当对话已成功时被调用，伴随一个 URL。
 */
- (void)dialogCompleteWithUrl:(NSURL *)url;

/**
 * 当对话被用户取消的时候被调用，伴随一个 URL。
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;

/**
 * 当对话已取消并即将消失时被调用。
 */
- (void)dialogDidNotComplete:(WDDialog *)dialog;

/**
 * 当对话由于一个错误而加载失败时被调用。
 */
- (void)dialog:(WDDialog *)dialog didFailWithError:(NSError *)error;

@end


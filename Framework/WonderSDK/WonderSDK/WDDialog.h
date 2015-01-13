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
* Displays the first page of the dialog.
*
* Do not ever call this directly.  It is intended to be overriden by subclasses.
*/
- (void)load;

/**
* Displays a URL in the dialog.
*/
- (void)loadURL:(NSString *)url get:(NSDictionary *)getParams;

/**
* Hides the view and notifies delegates of success or cancellation.
*/
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

/**
* Hides the view and notifies delegates of an error.
*/
- (void)dismissWithError:(NSError *)error animated:(BOOL)animated;

/**
* Subclasses may override to perform actions just prior to showing the dialog.
*/
- (void)dialogWillAppear;

/**
* Subclasses may override to perform actions just after the dialog is hidden.
*/
- (void)dialogWillDisappear;

/**
* Subclasses should override to process data returned from the server in a 'fbconnect' url.
*
* Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
*/
- (void)dialogDidSucceed:(NSURL *)url;

/**
* Subclasses should override to process data returned from the server in a 'fbconnect' url.
*
* Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
*/
- (void)dialogDidCancel:(NSURL *)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate
 */
@protocol WDDialogDelegate <NSObject>

@optional

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(WDDialog *)dialog;

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(WDDialog *)dialog;

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(WDDialog *)dialog didFailWithError:(NSError *)error;

@end


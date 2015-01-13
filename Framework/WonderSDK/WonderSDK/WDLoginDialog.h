//
//  WDLoginDialog.h
//  WonderSDK
//
//  Created by Wonder on 14/12/24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDDialog.h"
@protocol WDLoginDialogDelegate;

/**
 * Do not use this interface directly, instead, use authorize in WonderSDK.h
 *
 * WonderSDK Login Dialog interface for start the wondersdk webView login dialog.
 * It start pop-ups prompting for credentials and permissions.
 */

@interface WDLoginDialog : WDDialog

- (instancetype)initWithURL:(NSString *)loginURL
                loginParams:(NSMutableDictionary *)params
                   delegate:(id<WDLoginDialogDelegate>)loginDelegate;

@property (nonatomic, weak) id<WDLoginDialogDelegate> loginDelegate;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol WDLoginDialogDelegate <NSObject>

- (void)WDDialogLogin:(NSString *)token params:(NSDictionary *)params;

- (void)WDDialogNotLogin:(BOOL)cancelled;

@end

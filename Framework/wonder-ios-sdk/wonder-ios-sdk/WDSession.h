//
//  WDSession.h
//  WonderSDK
//
//  Created by Wonder on 14/12/22.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSession;

typedef void(^WDSessionCompleteHandler)(WDSession *session, NSError *error);

@interface WDSession : NSObject

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, copy, readonly) NSString *username;

/*!
 @method
 
 @abstract 打开 Wonder 登录会话.
 
 @discussion 必须在 WDSession 初始化后调用此方法。
 
 @param 会话完成后会回掉 block 处理程序。
 */
- (void)openWithCompletionHandler:(WDSessionCompleteHandler)handler;

@end

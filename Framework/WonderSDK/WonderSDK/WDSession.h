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

@property (nonatomic, copy) NSString *token;

- (void)openWithCompletionHandler:(WDSessionCompleteHandler)handler;

@end

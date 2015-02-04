//
//  WDUserStore.h
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDUser.h"

typedef void(^WDUserStoreSynchronizeCompletionHandler)(BOOL success);

@interface WDUserStore : NSObject

@property (nonatomic, copy) NSMutableArray *allUsers;
@property (nonatomic, strong) WDUser *currentUser;

+ (instancetype)sharedStore;
- (void)addUser:(WDUser *)user;
- (void)removeUser:(NSString *)username;
// 最后一次登录的用户
- (WDUser *)lastUser;
- (void)setCurrentUserWithUsername:(NSString *)username andPassword:(NSString *)password;
- (NSString *)stringWithJsonData;

- (void)synchronizeWithCompletionHandler:(WDUserStoreSynchronizeCompletionHandler)handler;

@end

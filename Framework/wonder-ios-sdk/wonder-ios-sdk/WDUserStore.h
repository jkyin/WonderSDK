//
//  WDUserStore.h
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDUser.h"

typedef void(^WDSaveAccountCompletionHandler)(BOOL success);

@interface WDUserStore : NSObject

@property (strong, nonatomic) NSMutableArray *allUsers;
@property (strong, nonatomic) WDUser *currentUser;

+ (instancetype)sharedStore;
- (void)addUser:(WDUser *)user;
- (void)removeUser:(NSString *)username;
- (WDUser *)lastUser;
- (NSMutableArray *)allUsers;
- (void)setCurrentUserWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)saveAccountChangesWithCompletionHandler:(WDSaveAccountCompletionHandler)completionHandler;
- (NSString *)stringWithJsonData;

@end

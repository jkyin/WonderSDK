//
//  WonderUserStore.h
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WonderUser.h"

typedef void(^WDSaveAccountCompletionHandler)(BOOL success);

@interface WDUserStore : NSObject

@property (strong, nonatomic) NSMutableArray *allUsers;
@property (strong, nonatomic) WonderUser *currentUser;

+ (instancetype)sharedStore;

- (void)addUser:(WonderUser *)user;
- (void)removeUser:(NSString *)userName;
- (WonderUser *)lastUser;
- (NSArray *)allUsers;

- (void)saveAccountChangesWithCompletionHandler:(WDSaveAccountCompletionHandler)completionHandler;

- (NSString *)stringWithJsonData;

@end

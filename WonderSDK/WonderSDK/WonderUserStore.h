//
//  WonderUserStore.h
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WonderUser.h"

@interface WonderUserStore : NSObject

@property (strong, nonatomic) NSMutableArray *allUsers;
@property (strong, nonatomic) WonderUser *currentUser;

+ (instancetype)sharedStore;

- (void)addUser:(WonderUser *)user;
- (void)removeUser:(NSString *)userName;
- (WonderUser *)lastUser;
- (NSArray *)allUsers;
- (BOOL)saveChanges;

- (NSString *)stringWithJsonData;

@end

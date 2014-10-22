//
//  WonderUserStore.m
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderUserStore.h"
#import "WonderUser.h"

@implementation WonderUserStore

+ (instancetype)sharedStore {
    static id sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [self userArchivePath];
        _allUsers = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_allUsers) {
            _allUsers = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

#pragma mark - Pulibc method

- (void)addUser:(WonderUser *)user {
    [self removeTheSameUser:user];
    [_allUsers addObject:user];
}

- (void)removeUser:(NSString *)userName {
    [_allUsers enumerateObjectsUsingBlock:^(WonderUser *obj, NSUInteger idx, BOOL *stop) {
        if ([userName isEqualToString:obj.userName]) {
            [_allUsers removeObject:obj];
        }
    }];
}

- (NSArray *)allUsers {
    return _allUsers;
}

- (WonderUser *)lastUser {
    return [[self allUsers] lastObject];
}

- (BOOL)saveChanges {
    NSString *path = [self userArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:_allUsers toFile:path];
}

- (NSString *)stringWithJsonData {
    __block NSMutableArray *userNameArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *passWordArray = [[NSMutableArray alloc] init];
    [_allUsers enumerateObjectsUsingBlock:^(WonderUser *obj, NSUInteger idx, BOOL *stop) {
        [userNameArray addObject:obj.userName];
        [passWordArray addObject:obj.passWord];
    }];
    
    NSDictionary *userDictionary = @{@"username" : userNameArray,
                                     @"password" : passWordArray
                                     };
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:userDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *base64EncodeString = [[NSString alloc] init];
    
    if ([json respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        // iOS 7+
        base64EncodeString = [json base64EncodedStringWithOptions:kNilOptions];
    } else {
        // pre iOS 7
        base64EncodeString = [json base64Encoding];
    }
    
    return base64EncodeString;
}

#pragma mark - Helper methods

- (void)removeTheSameUser:(WonderUser *)user {
    [_allUsers enumerateObjectsUsingBlock:^(WonderUser *obj, NSUInteger idx, BOOL *stop) {
        if ([user.userName isEqualToString:obj.userName]) {
            [_allUsers removeObject:obj];
        }
    }];
}

// Document 路径
- (NSString *)userArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"user.archive"];
}

@end

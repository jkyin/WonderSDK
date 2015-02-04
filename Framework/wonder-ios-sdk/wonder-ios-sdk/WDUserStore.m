//
//  WDUserStore.m
//  WonderSDK
//
//  Created by Wonder on 14-9-29.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDUserStore.h"

#import "WDUser.h"

@implementation WDUserStore

#pragma mark - Lifecycle

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[WDUserStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
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

+ (instancetype)sharedStore {
    static id sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (void)addUser:(WDUser *)user {
    // 首先删除重复的用户，
    // 再添加用户。
    [self removeUser:user.username];
    [self.allUsers addObject:user];
}

- (void)removeUser:(NSString *)username {
    WDUserStore * __weak weakSelf = self;
    [self.allUsers enumerateObjectsUsingBlock:^(WDUser *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.username isEqualToString:username]) {
            [weakSelf.allUsers removeObject:obj];
        }
    }];
}

- (WDUser *)lastUser {
    return self.allUsers.lastObject;
}

- (void)setCurrentUserWithUsername:(NSString *)username andPassword:(NSString *)password {
    WDUser *user = [[WDUser alloc] initWithUsername:username password:password];
    self.currentUser = user;
}

- (void)synchronizeWithCompletionHandler:(WDUserStoreSynchronizeCompletionHandler)handler {
    NSString *path = [self userArchivePath];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.allUsers toFile:path];
    if (success) {
        handler(success);
    } else {
        handler(NO);
    }
}

- (NSString *)stringWithJsonData {
    __block NSMutableArray *usernameArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *passwordArray = [[NSMutableArray alloc] init];
    [self.allUsers enumerateObjectsUsingBlock:^(WDUser *obj, NSUInteger idx, BOOL *stop) {
        [usernameArray addObject:obj.username];
        [passwordArray addObject:obj.password];
    }];
    
    NSDictionary *userDictionary = @{@"username" : usernameArray,
                                     @"password" : passwordArray
                                     };
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:userDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *base64EncodeString;
    
    if ([json respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        // iOS 7 later
        base64EncodeString = [json base64EncodedStringWithOptions:kNilOptions];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // iOS 7 earlier
        base64EncodeString = [json base64Encoding];
#pragma clang diagnostic pop
    }
    
    return base64EncodeString;
}

#pragma mark - Private

// Document 路径
- (NSString *)userArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    
    return [documentDirectory stringByAppendingPathComponent:@"user.archive"];
}

@end

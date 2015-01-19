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

// If a programmer calls [[WDUserStore alloc] init], let him
// know the error of his ways
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
    [self removeTheSameUser:user];
    [_allUsers addObject:user];
}

- (void)removeUser:(NSString *)username {
    [_allUsers enumerateObjectsUsingBlock:^(WDUser *obj, NSUInteger idx, BOOL *stop) {
        if ([username isEqualToString:obj.userName]) {
            [_allUsers removeObject:obj];
        }
    }];
}

- (NSMutableArray *)allUsers {
    return _allUsers;
}

- (WDUser *)lastUser {
    return [[self allUsers] lastObject];
}

- (void)setCurrentUserWithUsername:(NSString *)username andPassword:(NSString *)password {
    WDUser *user = [[WDUser alloc] initWithUsername:username password:password];
    self.currentUser = user;
}

- (void)saveAccountChangesWithCompletionHandler:(WDSaveAccountCompletionHandler)completionHandler {
    NSString *path = [self userArchivePath];
    BOOL success = [NSKeyedArchiver archiveRootObject:_allUsers toFile:path];
    if (success) {
        completionHandler(success);
    } else {
        completionHandler(NO);
    }
}

- (NSString *)stringWithJsonData {
    __block NSMutableArray *userNameArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *passWordArray = [[NSMutableArray alloc] init];
    [_allUsers enumerateObjectsUsingBlock:^(WDUser *obj, NSUInteger idx, BOOL *stop) {
        [userNameArray addObject:obj.userName];
        [passWordArray addObject:obj.passWord];
    }];
    
    NSDictionary *userDictionary = @{@"username" : userNameArray,
                                     @"password" : passWordArray
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

- (void)removeTheSameUser:(WDUser *)user {
    [_allUsers enumerateObjectsUsingBlock:^(WDUser *obj, NSUInteger idx, BOOL *stop) {
        if ([user.userName isEqualToString:obj.userName]) {
            [_allUsers removeObject:obj];
        }
    }];
}

// Document 路径
- (NSString *)userArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    
    return [documentDirectory stringByAppendingPathComponent:@"user.archive"];
}

@end

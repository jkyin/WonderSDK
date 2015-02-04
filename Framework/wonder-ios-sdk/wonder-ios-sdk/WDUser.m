//
//  WDUser.m
//  WonderSDK
//
//  Created by Wonder on 14-9-24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDUser.h"

@interface WDUser ()

@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *password;

@end

//----------------------------------------------------------------------------------------------------//
// 不要更改这个类的类名，否则会在读取本地 user.archive 文件时会发生以下错误：                                   //
// *** Terminating app due to uncaught exception 'NSInvalidUnarchiveOperationException', reason: '*** //
// -[NSKeyedUnarchiver decodeObjectForKey:]: cannot decode object of class (WDUser)'                  //
//----------------------------------------------------------------------------------------------------//
@implementation WDUser

- (instancetype)init {
    NSAssert(false, @"Please do not initialize WDUser directly. Use initWithUsername:(NSString *)username password:(NSString *)password instead.");
    assert(false);
    
    return nil;
}

- (void)dealloc {
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
    }
    
    return self;
}

#pragma mark - Custom Accesser

- (NSString *)userName {
    if (!_username) {
        _username = [[NSString alloc] init];
    }
    
    return _username;
}

- (NSString *)passWord {
    if (!_password) {
        _password = [[NSString alloc] init];
    }
    
    return _password;
}

#pragma mark - NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setPassword:[aDecoder decodeObjectForKey:@"password"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.password forKey:@"password"];
}

@end

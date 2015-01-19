//
//  WDUser.m
//  WonderSDK
//
//  Created by Wonder on 14-9-24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDUser.h"

@interface WDUser ()

@property (strong, readwrite, nonatomic) NSString *userName;
@property (strong, readwrite, nonatomic) NSString *passWord;

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

- (WDUser *)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _userName = username;
        _passWord = password;
    }
    
    return self;
}

#pragma mark - Custom Accesser

- (NSString *)userName {
    if (!_userName) {
        _userName = [[NSString alloc] init];
    }
    
    return _userName;
}

- (NSString *)passWord {
    if (!_passWord) {
        _passWord = [[NSString alloc] init];
    }
    
    return _passWord;
}

#pragma mark - NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setUserName:[aDecoder decodeObjectForKey:@"userName"]];
        [self setPassWord:[aDecoder decodeObjectForKey:@"passWord"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_userName forKey:@"userName"];
    [aCoder encodeObject:_passWord forKey:@"passWord"];
}

@end

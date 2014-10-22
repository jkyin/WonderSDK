//
//  WonderUser.m
//  WonderSDK
//
//  Created by Wonder on 14-9-24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderUser.h"

@interface WonderUser ()

@property (strong, readwrite, nonatomic) NSString *userName;
@property (strong, readwrite, nonatomic) NSString *passWord;

@end

@implementation WonderUser

- (instancetype)init {    
    NSAssert(NO, @"Please do not initialize WonderUser directly. Use initWithUsername:(NSString *)username AndPassword:(NSString *)password instead.");
    assert(NO);
}

- (WonderUser *)initWithUsername:(NSString *)username AndPassword:(NSString *)password {
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

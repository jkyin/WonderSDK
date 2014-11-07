//
//  WonderUser.h
//  WonderSDK
//
//  Created by Wonder on 14-9-24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WonderUser : NSObject <NSCoding>

@property (strong, readonly, nonatomic) NSString *userName;
@property (strong, readonly, nonatomic) NSString *passWord;

- (instancetype)init __attribute__((unavailable("Please do not initialize WonderUser directly. Use initWithUsername:password: instead.")));
- (WonderUser *)initWithUsername:(NSString *)username password:(NSString *)password;
@end

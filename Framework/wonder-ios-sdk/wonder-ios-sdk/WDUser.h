//
//  WDUser.h
//  WonderSDK
//
//  Created by Wonder on 14-9-24.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDUser : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;

- (instancetype)init __attribute__((unavailable("Please do not initialize WDUser directly. Use initWithUsername:password: instead.")));
- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

@end

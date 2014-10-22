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

- (WonderUser *)initWithUsername:(NSString *)username AndPassword:(NSString *)password;
@end

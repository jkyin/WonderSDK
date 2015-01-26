//
//  WonderURLParser.h
//  URLParser
//
//  Created by Wonder on 14-8-25.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDURLParser : NSObject

+ (NSString *)getValueForParameter:(NSString *)Param fromUrlString:(NSString *)urlString;

@end

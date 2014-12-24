//
//  WonderURLParser.m
//  URLParser
//
//  Created by Wonder on 14-8-25.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDURLParser.h"

@interface WDURLParser ()


@end

@implementation WDURLParser

/**
* 从 URL 得到指定参数的值
*/
+ (NSString *)getValueForParameter:(NSString *)Param fromUrlString:(NSString *)urlString {
    NSString *value;
    NSRange start = [urlString rangeOfString:Param];
    if (start.location != NSNotFound) {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0) {
            c = [urlString characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#') {
            NSRange end = [[urlString substringFromIndex:start.location + start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location + start.length;
            value = end.location == NSNotFound ?
                    [urlString substringFromIndex:offset] :
                    [urlString substringWithRange:NSMakeRange(offset, end.location)];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return value;
}


@end

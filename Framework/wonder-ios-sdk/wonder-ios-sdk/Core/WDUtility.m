//
//  WDUtility.m
//  WonderSDK
//
//  Created by Wonder on 14/12/30.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDUtility.h"

@implementation WDUtility

#pragma mark - URLs Params Encode / Decode

+ (NSDictionary *)queryParamsDictionaryFromWDURL:(NSURL *)url {
    // version 3.2.3 of the Facebook app encodes the parameters in the query but
    // version 3.3 and above encode the parameters in the fragment;
    // merge them together with fragment taking priority.
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if ([url query]) {
        [result addEntriesFromDictionary:[self dictionaryByParsingURLQueryPart:[url query]]];
    }
    if ([url fragment]) {
        [result addEntriesFromDictionary:[self dictionaryByParsingURLQueryPart:[url fragment]]];
    }
    
    return result;
}

// finishes the parsing job that NSURL starts
+ (NSDictionary *)dictionaryByParsingURLQueryPart:(NSString *)encodedString {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parts = [encodedString componentsSeparatedByString:@"&"];
    
    for (NSString *part in parts) {
        if ([part length] == 0) {
            continue;
        }
        
        NSRange index = [part rangeOfString:@"="];
        NSString *key;
        NSString *value;
        
        if (index.location == NSNotFound) {
            key = part;
            value = @"";
        } else {
            key = [part substringToIndex:index.location];
            value = [part substringFromIndex:index.location + index.length];
        }
        
        if (key && value) {
            [result setObject:[self stringByURLDecodingString:value]
                       forKey:[self stringByURLDecodingString:key]];
        }
    }
    return result;
}

// the reverse of url encoding
+ (NSString *)stringByURLDecodingString:(NSString *)escapedString {
    return [[escapedString stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)stringByURLEncodingString:(NSString *)unescapedString {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                           kCFAllocatorDefault,
                                                                           (CFStringRef)unescapedString,
                                                                           NULL, // characters to leave unescaped
                                                                           (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                           kCFStringEncodingUTF8));
    return result;
}

@end

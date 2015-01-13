//
//  WDUtility.h
//  WonderSDK
//
//  Created by Wonder on 14/12/30.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDUtility : NSObject

#pragma mark - URLs Params Encode / Decode

+ (NSDictionary *)queryParamsDictionaryFromWDURL:(NSURL *)url;
+ (NSDictionary *)dictionaryByParsingURLQueryPart:(NSString *)encodedString;
//+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters;
+ (NSString *)stringByURLDecodingString:(NSString *)escapedString;
+ (NSString *)stringByURLEncodingString:(NSString *)unescapedString;

@end

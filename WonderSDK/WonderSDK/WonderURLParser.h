//
//  WonderURLParser.h
//  URLParser
//
//  Created by Wonder on 14-8-25.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WonderURLParser : NSObject

/**
 *  This method is the designated initializer for the class.
 *
 *  @param url incoming URL.
 *
 *  @return instance of the class.
 */
- (instancetype)initWithURLString:(NSString *)url;

/**
 *  Quering corresponding values of the designated variables.
 *
 *  @param varName variables name.
 *
 *  @return value of variable.
 */
- (NSString *)valueForVariable:(NSString *)varName;

@end

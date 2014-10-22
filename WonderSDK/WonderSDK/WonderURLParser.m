//
//  WonderURLParser.m
//  URLParser
//
//  Created by Wonder on 14-8-25.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderURLParser.h"

@interface WonderURLParser ()

@property (strong, nonatomic) NSArray *variables;

@end

@implementation WonderURLParser

- (instancetype)initWithURLString:(NSString *)string {
    self = [super init];
    if (self) {
        NSString *urlString = string;
        NSScanner *scanner = [NSScanner scannerWithString:urlString];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        
        NSString *tempString;
        NSMutableArray *vars = [[NSMutableArray alloc] init];
		// Ignore the beginning of the string and skip to the variables.
        [scanner scanUpToString:@"?" intoString:nil];
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:tempString];
        }
        _variables = vars;
    }
    
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in _variables) {
        if ([var length] > [varName length] + 1 && [[var substringWithRange:NSMakeRange(0, [varName length] + 1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length] + 1];
            return varValue;
        }
    }
    
    return nil;
}

@end

//
//  WonderLoadingView.m
//  WonderSDK
//
//  Created by Wonder on 14-9-30.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderLoadingView.h"

@implementation WonderLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
        self.layer.cornerRadius = 8;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.3f; // 阴影不透明度
        self.layer.shadowOffset = CGSizeMake(0, 5); // 阴影偏移量
        self.layer.shadowRadius = 10.0f; // 阴影模糊半径
        
        _wonderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.superview.frame.origin.x / 2.0f, 30, 250, 50)];
        _wonderLabel.backgroundColor = [UIColor clearColor];
        _wonderLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:_wonderLabel];
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.superview.frame.origin.x / 2.0f, 120, 120, 50)];
        _loadingLabel.font = [UIFont systemFontOfSize:20];
        _loadingLabel.text = @"正在登录......";
        _loadingLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_loadingLabel];
    }
    
    return self;
}

@end

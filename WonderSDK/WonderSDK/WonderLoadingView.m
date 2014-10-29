//
//  WonderLoadingView.m
//  WonderSDK
//
//  Created by Wonder on 14-9-30.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WonderLoadingView.h"

static const CGFloat WDLoadingViewLabelPadding = 30;

@interface WonderLoadingView ()

@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation WonderLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 0.3f; // 阴影不透明度
//        self.layer.shadowOffset = CGSizeMake(0, 5); // 阴影偏移量
//        self.layer.shadowRadius = 10.0f; // 阴影模糊半径
        self.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleBottomMargin |
                                 UIViewAutoresizingFlexibleTopMargin);
        
        _wonderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 30)];
        _wonderLabel.center = CGPointMake(CGRectGetMidX(self.frame), WDLoadingViewLabelPadding);
        _wonderLabel.backgroundColor = [UIColor clearColor]; //
        _wonderLabel.font = [UIFont systemFontOfSize:20];
        _wonderLabel.numberOfLines = 1;
        _wonderLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_wonderLabel];
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.center = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetHeight(self.frame) - WDLoadingViewLabelPadding));
        _loadingLabel.font = [UIFont systemFontOfSize:20];
        _loadingLabel.text = @"正在登录......";
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_loadingLabel];
    }
    
    return self;
}

@end

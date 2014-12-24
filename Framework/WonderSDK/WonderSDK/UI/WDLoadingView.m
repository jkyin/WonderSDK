//
//  WonderLoadingView.m
//  WonderSDK
//
//  Created by Wonder on 14-9-30.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

@import QuartzCore;

#import "WDLoadingView.h"
#import "UIView+WDGeometryLayout.h"
#import "WDUserStore.h"

static const CGFloat WDLoadingViewLabelPadding = 58;

@interface WDLoadingView ()
@property (nonatomic, strong) WDDotsProgressIndicator *dotsProgressIndicator;
@end

@implementation WDLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleBottomMargin |
                                 UIViewAutoresizingFlexibleTopMargin);
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDLoadingViewBackground"]];
        [self addSubview:backgroundImage];
        
        /* _wonderLabel 设置 */
        UILabel *wonderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        wonderLabel.backgroundColor = [UIColor clearColor];
        wonderLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:25];
        wonderLabel.text = [NSString stringWithFormat:@"%@", [WDUserStore sharedStore].currentUser.userName];
        wonderLabel.numberOfLines = 0;
        wonderLabel.textAlignment = NSTextAlignmentCenter;
        // 调整 UILabel 大小来适配文本内容
        CGSize maxSize = CGSizeMake(200, 30);
        CGSize textSize = [wonderLabel.text sizeWithFont:wonderLabel.font constrainedToSize:maxSize];
        CGRect wonderLabelFrame = wonderLabel.frame;
        wonderLabelFrame.size.width = ceilf(textSize.width);
        wonderLabelFrame.size.height = ceilf(textSize.height);
        wonderLabel.frame = wonderLabelFrame;
        // 居中 _wonderLabel
        CGPoint wonderLabelCenter = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2 - 20);
        wonderLabel.center = wonderLabelCenter;
        [self addSubview:wonderLabel];
        
        // accountImageView 配置
        UIImageView *accountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WonderSDK.bundle/WDAccount"]];
        CGPoint center = accountImageView.center;
        center.x = wonderLabel.frameOriginX - accountImageView.frameWidth/2 - 8;
        center.y = CGRectGetMidY(wonderLabel.frame);
        accountImageView.center = center;
        [self addSubview:accountImageView];
        
        // 「登录指示器」设置
        self.dotsProgressIndicator = [[WDDotsProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
        self.dotsProgressIndicator.backgroundColor = [UIColor clearColor];
        self.dotsProgressIndicator.center = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetHeight(self.frame) - WDLoadingViewLabelPadding));
        self.dotsProgressIndicator.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20];
        [self.dotsProgressIndicator startAnimating];
        [self addSubview:self.dotsProgressIndicator];
    }
    
    return self;
}

- (void)stopAnimating {
    [self.dotsProgressIndicator stopAnimating];
}

- (void)dealloc {
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

@end

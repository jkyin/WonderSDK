//
//  dotIndicatorView.m
//  test1111111
//
//  Created by Wonder on 14/12/2.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "WDDotsProgressIndicator.h"

@interface WDDotsProgressIndicator ()

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation WDDotsProgressIndicator

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%@ dealloc!", NSStringFromClass([self class]));
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefault];
    }
    
    return self;
}

- (void)setupDefault {
    self.text = @"正在登录";
    self.interval = 0.5f;
    self.numbersOfDots = 6;
}

- (void)startAnimating {
    [self adjustBounds];
    self.isAnimating = YES;
    __weak WDDotsProgressIndicator *weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.interval target:weakSelf selector:@selector(appendDot:) userInfo:nil repeats:YES];
}

- (void)stopAnimating {
    self.isAnimating = NO;
    [_timer invalidate];
    [self removeFromSuperview];
}

- (void)appendDot:(NSTimer *)timer {
    if (self.text.length < self.numbersOfDots + 4) {
        self.text = [self.text stringByAppendingString:@"."];
        NSDate *endDate = [NSDate date];
        NSLog(@"%@", endDate);
    } else {
        self.text = @"正在登录";
    }
}

- (void)adjustBounds {
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.text = @"正在登录......";
    CGSize textSize = [resultLabel.text sizeWithFont:self.font];
    CGRect bounds = self.bounds;
    bounds.size.width = ceilf(textSize.width);
    bounds.size.height = ceilf(textSize.height);
    self.bounds = bounds;
}

@end

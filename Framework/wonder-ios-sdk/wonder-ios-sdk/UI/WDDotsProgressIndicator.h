//
//  dotIndicatorView.h
//  test1111111
//
//  Created by Wonder on 14/12/2.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDotsProgressIndicator : UILabel

@property (nonatomic, assign) NSUInteger numbersOfDots;
@property (nonatomic, assign) NSTimeInterval interval;

- (void)startAnimating;
- (void)stopAnimating;
@end

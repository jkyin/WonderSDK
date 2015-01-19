//
//  UIView+WDGeometryLayout.h
//  WonderSDK
//
//  Created by Wonder on 14/11/28.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - View Alignment

typedef NS_ENUM(NSUInteger, WDViewAlignment) {
    WDViewAlignmentTopLeft,
    WDViewAlignmentTopCenter,
    WDViewAlignmentTopRight,
    WDViewAlignmentMiddleLeft,
    WDViewAlignmentCenter,
    WDViewAlignmentMiddleRight,
    WDViewAlignmentBottomLeft,
    WDViewAlignmentBottomCenter,
    WDViewAlignmentBottomRight,
};

@interface UIView (WDGeometryLayout)

//--------------------------------------------
// layout property related to super coordinate
//--------------------------------------------
#pragma mark - Frame Positioning

@property (nonatomic) CGFloat frameWidth;    // view.frame.size.width
@property (nonatomic) CGFloat frameHeight;   // view.frame.size.height
@property (nonatomic) CGFloat frameOriginX;  // view.frame.origin.x
@property (nonatomic) CGFloat frameOriginY;  // view.frame.origin.y
@property (nonatomic) CGPoint frameOrigin;   // view.frame.origin
@property (nonatomic) CGSize frameSize;      // view.frame.size

// The point at the center of view's bounds.
// So it's not related to super view.
@property (nonatomic, readonly) CGPoint boundsCenter;

// Returns the smallest rectangle that results from converting the source rectangle values to integers.
- (void)frameIntegral;

/**
 *  Align specified point with View A.
 *
 *  @param alignment alignment syles.
 *  @param point relative point.
 */
- (void)align:(WDViewAlignment)alignment relativeToPoint:(CGPoint)point;

/**
 *  Align rectangle B with View A.
 *
 *  @param alignment alignment syles.
 *  @param rectangle relative rectangle.
 */
- (void)align:(WDViewAlignment)alignment relativeToRectangle:(CGRect)rectangle;

@end

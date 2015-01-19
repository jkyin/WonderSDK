//
//  UIView+WDGeometryLayout.m
//  WonderSDK
//
//  Created by Wonder on 14/11/28.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import "UIView+WDGeometryLayout.h"

@implementation UIView (WDGeometryLayout)

#pragma mark - Frame

/* Width */

- (CGFloat)frameWidth {
    return CGRectGetWidth(self.frame);
}

- (void)setFrameWidth:(CGFloat)frameWidth {
    CGRect frame = self.frame;
    frame.size.width = frameWidth;
    self.frame = frame;
}

/* Height */

- (CGFloat)frameHeight {
    return CGRectGetHeight(self.frame);
}

- (void)setFrameHeight:(CGFloat)frameHeight {
    CGRect frame = self.frame;
    frame.size.height = frameHeight;
    self.frame = frame;
}

/* Point X */

- (CGFloat)frameOriginX {
    return CGRectGetMinX(self.frame);
}

- (void)setFrameOriginX:(CGFloat)frameOriginX {
    CGRect frame = self.frame;
    frame.origin.x = frameOriginX;
    self.frame = frame;
}

/* Point Y */

- (CGFloat)frameOriginY {
    return CGRectGetMinY(self.frame);
}

- (void)setFrameOriginY:(CGFloat)frameOriginY {
    CGRect frame = self.frame;
    frame.origin.y = frameOriginY;
    self.frame = frame;
}

/* Origin */

- (CGPoint)frameOrigin {
    return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)frameOrigin {
    self.frameOriginX = frameOrigin.x;
    self.frameOriginY = frameOrigin.y;
}

/* Frame Size */

- (CGSize)frameSize {
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize {
    self.frameWidth = frameSize.width;
    self.frameHeight = frameSize.height;
}

#pragma mark - Bounds

/* Bounds Center */

- (CGPoint)boundsCenter {
    return CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

#pragma mark - Public

- (void)frameIntegral {
    self.frame = CGRectIntegral(self.frame);
}

- (void)align:(WDViewAlignment)alignment relativeToPoint:(CGPoint)point {
    switch (alignment) {
        case WDViewAlignmentTopLeft:
            self.frameOrigin = point;
            break;
        case WDViewAlignmentTopCenter:
            self.frameOrigin = CGPointMake(point.x - self.frameWidth/2, point.y);
            break;
        case WDViewAlignmentTopRight:
            self.frameOrigin = CGPointMake(point.x - self.frameWidth, point.y);
            break;
        case WDViewAlignmentMiddleLeft:
            self.frameOrigin = CGPointMake(point.x, point.y - self.frameHeight/2);
            break;
        case WDViewAlignmentCenter:
            self.center = point;
            break;
        case WDViewAlignmentMiddleRight:
            self.frameOrigin = CGPointMake(point.x - self.frameWidth, point.y - self.frameHeight/2);
            break;
        case WDViewAlignmentBottomLeft:
            self.frameOrigin = CGPointMake(point.x, point.y - self.frameHeight);
            break;
        case WDViewAlignmentBottomCenter:
            self.frameOrigin = CGPointMake(point.x - self.frameWidth/2, point.y - self.frameHeight);
            break;
        case WDViewAlignmentBottomRight:
            self.frameOrigin = CGPointMake(point.x - self.frameWidth, point.y - self.frameHeight);
            break;
        default:
            break;
    }
    
    [self frameIntegral];
}

- (void)align:(WDViewAlignment)alignment relativeToRectangle:(CGRect)rectangle {
    CGPoint point = CGPointZero;
    switch (alignment) {
        case WDViewAlignmentTopLeft:
            point = rectangle.origin;
            break;
        case WDViewAlignmentTopCenter:
            point = CGPointMake(CGRectGetMinX(rectangle) + CGRectGetWidth(rectangle)/2, CGRectGetMinY(rectangle));
            break;
        case WDViewAlignmentTopRight:
            point = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMinY(rectangle));
            break;
        case WDViewAlignmentMiddleLeft:
            point = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMinY(rectangle) + CGRectGetHeight(rectangle)/2);
            break;
        case WDViewAlignmentCenter:
            point = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
            break;
        case WDViewAlignmentMiddleRight:
            point = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMinY(rectangle) + CGRectGetHeight(rectangle)/2);
            break;
        case WDViewAlignmentBottomLeft:
            point = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMaxY(rectangle));
            break;
        case WDViewAlignmentBottomCenter:
            point = CGPointMake(CGRectGetMinX(rectangle) + CGRectGetWidth(rectangle)/2, CGRectGetMaxY(rectangle));
            break;
        case WDViewAlignmentBottomRight:
            point = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMaxY(rectangle));
            break;
        default:
            break;
    }
    
    [self align:alignment relativeToPoint:point];
}

@end


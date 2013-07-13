//
//  WTCGAdditions.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-23.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void WTCGContextDrawLinearGradientBetweenPoints(CGContextRef context, CGPoint a, CGFloat color_a, CGPoint b, CGFloat color_b, CGFloat alpha);
extern void WTCGContextDrawGradientLine(CGContextRef ctx,CGRect leftPart,CGRect midPart,CGRect rightPart,CGFloat edgeColor, CGFloat midColor);

extern void WUIDrawGradientBetweenPointsWithColor(CGContextRef context, CGPoint a, TUIColor * color_a, CGPoint b, TUIColor * color_b);

extern void CGContextSetHEXAFillColor(CGContextRef context, NSInteger hex, CGFloat alpha);

extern CGMutablePathRef createRoundedPathForRect(CGRect rect, CGFloat radius);
extern CGMutablePathRef createTopBottomRoundedPathForRect(CGRect rect, CGFloat topRadius,CGFloat bottomRadius);
extern CGMutablePathRef createLeftRightRoundedPathForRect(CGRect rect, CGFloat leftRadius,CGFloat rightRadius);

extern void WTCGContextAddTopBottomRoundRect(CGContextRef context, CGRect rect, CGFloat topRadius, CGFloat bottomRadius);
extern void WTCGContextClipToTopBottomRoundRect(CGContextRef context, CGRect rect, CGFloat topRadius, CGFloat bottomRadius);

extern void WTCUIDraw(CGContextRef ctx, CGRect rect, BOOL active);

enum {
    WUICellBackgroundColorNormal = 0,
    WUICellBackgroundColorBlue,
    WUICellBackgroundColorSuperBlue,
};
typedef NSInteger WUICellBackgroundColor;

extern void WUIDrawCellBackground(CGContextRef ctx, CGRect b, WUICellBackgroundColor color, BOOL selected, BOOL mouseInside);
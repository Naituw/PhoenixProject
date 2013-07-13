//
//  WTCGAdditions.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-23.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTCGAdditions.h"

typedef CFTypeRef CUIRendererRef;
extern void CUIDraw (CUIRendererRef r, CGRect rect, CGContextRef ctx, CFDictionaryRef options, CFDictionaryRef * result);

@interface NSWindow(CoreUIRendererPrivate)
+ (CUIRendererRef)coreUIRenderer;
@end

void WTCGContextDrawLinearGradientBetweenPoints(CGContextRef context, CGPoint a, CGFloat color_a, CGPoint b, CGFloat color_b, CGFloat alpha)
{
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = { color_a, color_a, color_a, alpha, color_b, color_b, color_b, alpha};
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, NULL, 2);
	CGContextDrawLinearGradient(context, gradient, a, b, 0);
	CGColorSpaceRelease(colorspace);
	CGGradientRelease(gradient);
}

void WTCGContextDrawGradientLine(CGContextRef ctx,CGRect leftPart,CGRect midPart,CGRect rightPart,CGFloat edgeColor, CGFloat midColor){
    {
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx,leftPart);
        CGContextClip(ctx);
        WTCGContextDrawLinearGradientBetweenPoints(ctx, 
                                                   CGPointMake(leftPart.origin.x, 0) , edgeColor,
                                                   CGPointMake(leftPart.size.width,0), midColor, 
                                                   1.0);
        CGContextRestoreGState(ctx);
    }
    {
        CGContextSetRGBFillColor(ctx, midColor, midColor, midColor, 1.0);
        CGContextFillRect(ctx, midPart);
    }
    {
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx,rightPart);
        CGContextClip(ctx);
        WTCGContextDrawLinearGradientBetweenPoints(ctx, 
                                                   CGPointMake(rightPart.origin.x, 0) , midColor,
                                                   CGPointMake(rightPart.size.width,0), edgeColor, 
                                                   1.0);
        CGContextRestoreGState(ctx);
    }
}

void WUIDrawGradientBetweenPointsWithColor(CGContextRef context, CGPoint a, TUIColor * color_a, CGPoint b, TUIColor * color_b)
{
    if (!(CGColorGetNumberOfComponents(color_a.CGColor) == 4 &&
         CGColorGetNumberOfComponents(color_b.CGColor) == 4))
    {
        NSLog(@"[WUIDrawGradientBetweenPointsWithColor] Must pass in two RGBA color");
        return;
    }
    
    const CGFloat * ca = CGColorGetComponents(color_a.CGColor);
    const CGFloat * cb = CGColorGetComponents(color_b.CGColor);
    
    CGFloat ca_r = ca[0], ca_g = ca[1], ca_b = ca[2], ca_a = ca[3];
    CGFloat cb_r = cb[0], cb_g = cb[1], cb_b = cb[2], cb_a = cb[3];
    
    CGFloat comp_a[] = {ca_r, ca_g, ca_b, ca_a};
    CGFloat comp_b[] = {cb_r, cb_g, cb_b, cb_a};
    
    CGContextDrawLinearGradientBetweenPoints(context, a, comp_a, b, comp_b);
}

void CGContextSetHEXAFillColor(CGContextRef context, NSInteger hex, CGFloat alpha)
{
    CGFloat r = ((float)((hex & 0xFF0000) >> 16))/255.0,
    g = ((float)((hex & 0xFF00) >> 8))/255.0,
    b = ((float)(hex & 0xFF))/255.0;

    CGContextSetRGBFillColor(context, r, g, b, alpha);
}

CGMutablePathRef createRoundedPathForRect(CGRect rect, CGFloat radius) {
    return createLeftRightRoundedPathForRect(rect, radius, radius);        
}


CGMutablePathRef createLeftRightRoundedPathForRect(CGRect rect, CGFloat leftRadius,CGFloat rightRadius){
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMaxY(rect), rightRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMaxY(rect), rightRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMinY(rect), leftRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMinY(rect), leftRadius);
    CGPathCloseSubpath(path);
    
    return path;  
}

CGMutablePathRef createTopBottomRoundedPathForRect(CGRect rect, CGFloat topRadius,CGFloat bottomRadius){
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMaxY(rect), bottomRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMaxY(rect), topRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMinY(rect), topRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMinY(rect), bottomRadius);
    CGPathCloseSubpath(path);
    
    return path;  
}

void WTCGContextAddTopBottomRoundRect(CGContextRef context, CGRect rect, CGFloat topRadius, CGFloat bottomRadius){
    topRadius = MIN(topRadius, rect.size.width / 2);
	topRadius = MIN(topRadius, rect.size.height / 2);
	topRadius = floor(topRadius);
    bottomRadius = MIN(bottomRadius, rect.size.width / 2);
	bottomRadius = MIN(bottomRadius, rect.size.height / 2);
	bottomRadius = floor(bottomRadius);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + bottomRadius);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - topRadius);
	CGContextAddArc(context, rect.origin.x + topRadius, rect.origin.y + rect.size.height - topRadius, topRadius, M_PI, M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - topRadius, rect.origin.y + rect.size.height);
	CGContextAddArc(context, rect.origin.x + rect.size.width - topRadius, rect.origin.y + rect.size.height - topRadius, topRadius, M_PI / 2, 0.0f, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + bottomRadius);
	CGContextAddArc(context, rect.origin.x + rect.size.width - bottomRadius, rect.origin.y + bottomRadius, bottomRadius, 0.0f, -M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + bottomRadius, rect.origin.y);
	CGContextAddArc(context, rect.origin.x + bottomRadius, rect.origin.y + bottomRadius, bottomRadius, -M_PI / 2, M_PI, 1);
}
void WTCGContextClipToTopBottomRoundRect(CGContextRef context, CGRect rect, CGFloat topRadius, CGFloat bottomRadius){
    CGPathRef path = createTopBottomRoundedPathForRect(rect, topRadius, bottomRadius);
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    /*
    CGContextBeginPath(context);
	WTCGContextAddTopBottomRoundRect(context, rect, topRadius, bottomRadius);
	CGContextClosePath(context);
     */
	CGContextClip(context);
    CGPathRelease(path);
}


void WTCUIDraw(CGContextRef ctx, CGRect rect, BOOL active){
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:7];
    //[dict setObject:@"kCUIWidgetWindowBottomBar" forKey:@"widget"];
    [dict setObject:@"kCUIWidgetWindowFrame" forKey:@"widget"];
    [dict setObject:@"regularwin" forKey:@"windowtype"];
    //[dict setObject:@"kCUIWindowTypeTextured" forKey:@"windowtype"];
    [dict setObject:active?@"normal":@"inactive" forKey:@"state"];
    [dict setObject:[NSNumber numberWithInt:rect.size.height] forKey:@"kCUIWindowFrameUnifiedTitleBarHeightKey"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"kCUIWindowFrameBottomBarHeightKey"];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"kCUIWindowFrameDrawTitleSeparatorKey"];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"kCUIWindowFrameDrawBottomBarSeparatorKey"];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"kCUIWindowFrameRoundedBottomCornersKey"];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"is.flipped"];
    
    CUIDraw([NSWindow coreUIRenderer],
            rect,
            ctx,
            (CFDictionaryRef)dict,
            nil);
}



void WUIDrawCellBackground(CGContextRef ctx, CGRect b, WUICellBackgroundColor color, BOOL selected, BOOL mouseInside)
{
    CGPoint top = CGPointMake(0, b.size.height);
    CGPoint bottom = CGPointMake(0, 0);
    
    if (color == WUICellBackgroundColorSuperBlue)
    {
        // gray gradient
        CGFloat colorA[] = { 222.0/255.0, 226.0/255.0, 228.0/255.0, 1.0 };
        CGFloat colorB[] = { 192.0/255.0, 199.0/255.0, 207.0/255.0, 1.0 };
        CGContextDrawLinearGradientBetweenPoints(ctx, top, colorA, bottom, colorB);
		
		// emboss
		CGContextSetRGBFillColor(ctx, 177.0/255.0, 185.0/255.0, 192.0/255.0, 1.0); // light at the top
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
		CGContextSetRGBFillColor(ctx, 153.0/255.0, 165.0/255.0, 175.0/255.0, 1.0); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    }
    else if (color == WUICellBackgroundColorBlue)
    {        
        WUIDrawGradientBetweenPointsWithColor(ctx, top, TUIHEXColor(0x83c4ef), bottom, TUIHEXColor(0x1f86ff));
		
		// emboss
        CGContextSetHEXAFillColor(ctx, 0x5086eb, 1.0);
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
        CGContextSetHEXAFillColor(ctx, 0x0c39ac, 1.0);
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    }
    else if (selected)
    {
		// gray gradient
        
        CGFloat colorA[] = { 221.0/255.0, 221.0/255.0, 221.0/255.0, 1.0 };
        CGFloat colorB[] = { 234.0/255.0, 234.0/255.0, 234.0/255.0, 1.0 };
        CGContextDrawLinearGradientBetweenPoints(ctx,
                                                 CGPointMake(0, b.size.height)  , colorA,
                                                 CGPointMake(0, b.size.height-5), colorB);
        
        CGFloat colorC[] = { 234.0/255.0, 234.0/255.0, 234.0/255.0, 1.0 };
        CGFloat colorD[] = { 244.0/255.0, 244.0/255.0, 244.0/255.0, 1.0 };
        CGContextDrawLinearGradientBetweenPoints(ctx,
                                                 CGPointMake(0, b.size.height-5), colorC,
                                                 CGPointMake(0, 0)              , colorD);
		// emboss
		CGContextSetRGBFillColor(ctx, 182.0/255.0, 182.0/255.0, 182.0/255.0, 1.0); // light at the top
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
        CGContextSetRGBFillColor(ctx, 235.0/255.0, 235.0/255.0, 235.0/255.0, 1.0); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 1, b.size.width, 1));
		CGContextSetRGBFillColor(ctx, 211.0/255.0, 211.0/255.0, 211.0/255.0, 1.0); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
	}
    else
    {
        if (mouseInside) {
            // gray gradient
            CGFloat colorA[] = { 1,1,1, 1.0 };
            CGFloat colorB[] = { 251.0/255.0, 251.0/255.0, 251.0/255.0, 1.0 };
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), colorA, CGPointMake(0, 0), colorB);
        }else {
            // gray gradient
            CGFloat colorA[] = { 251.0/255.0, 251.0/255.0, 251.0/255.0, 1.0 };
            CGFloat colorB[] = { 247.0/255.0, 247.0/255.0, 247.0/255.0, 1.0 };
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), colorA, CGPointMake(0, 0), colorB);
        }
        
        
		
		// emboss
		CGContextSetRGBFillColor(ctx, 254.0/255.0, 254.0/255.0, 254.0/255.0, 1.0); // light at the top
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
		CGContextSetRGBFillColor(ctx, 235.0/255.0, 235.0/255.0, 235.0/255.0, 1.0); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
	}
}

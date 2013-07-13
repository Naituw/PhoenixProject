//
//  WMGroupedCell.m
//  Example
//
//  Created by Wu Tian on 12-4-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedCell.h"
#import "TUIKit.h"
#import "WTCGAdditions.h"

@implementation WMGroupedCell

@synthesize isFirstRow = _isFirstRow, isLastRow = _isLastRow;
@synthesize paddingLeftRight = _paddingLeftRight;
@synthesize canPerformAction = _canPerformAction;
@synthesize rowIndex = _rowIndex, allRows = _allRows;

- (void)prepareForReuse{
    self.isFirstRow = NO;
    self.isLastRow = NO;
    self.canPerformAction = NO;
}

- (void)drawCellContent:(CGRect)b{
    
}

- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect cb = self.bounds;
    CGRect b = self.bounds;
    b.size.width -= 2* self.paddingLeftRight;
    b.origin.x += self.paddingLeftRight;
    
    [self.backgroundColor set];
    CGContextFillRect(ctx, self.bounds);
    
    CGFloat defaultRoundRadius = 4.0;
    CGFloat topRadius = self.isFirstRow?defaultRoundRadius:0, 
            bottomRadius = self.isLastRow?defaultRoundRadius:0;

    
    CGContextSaveGState(ctx);
    
    if (self.isLastRow) {
        WTCGContextClipToTopBottomRoundRect(ctx, b, topRadius?topRadius + 1:0, bottomRadius?bottomRadius + 1:0);
        [[TUIColor whiteColor] set];
        CGContextFillRect(ctx, rect);
        b.origin.y += 1;
    }
    
    WTCGContextClipToTopBottomRoundRect(ctx, b, topRadius?topRadius + 1:0, bottomRadius?bottomRadius + 1:0);
    
    [[TUIColor colorWithWhite:208.0/255.0 alpha:1.0] set];
    CGContextFillRect(ctx, rect);
    
    b = CGRectInset(b, 1, 1);
        
    WTCGContextClipToTopBottomRoundRect(ctx, b, topRadius, bottomRadius);
    
    if ([self.nsView isTrackingSubviewOfView:self] && self.canPerformAction) {
        [[TUIColor colorWithWhite:250.0/255.0 alpha:1] set];
        CGContextFillRect(ctx, b);
    }else {
        /*
        [[TUIColor colorWithWhite:240.0/255.0 alpha:1] set];
        CGContextFillRect(ctx, self.bounds);
        */
        CGFloat rowColorDelta = (247.0-240.0)/(CGFloat)self.allRows;
        CGFloat topColor = 247.0 - self.rowIndex * rowColorDelta;
        CGFloat bottomColor = topColor - rowColorDelta;
        topColor /= 255.0;
        bottomColor /= 255.0;
        /*
        CGFloat topColor = 247.0/255.0;
        CGFloat bottomColor = 240.0/255.0;*/
        CGFloat colorA[] = {topColor,topColor,topColor,1};
        CGFloat colorB[] = {bottomColor,bottomColor,bottomColor,1};
        CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height + 1), colorA, CGPointMake(0, 1), colorB);
         
    }
        
    CGContextRestoreGState(ctx);
    
    if (!self.isFirstRow) {
        [[TUIColor colorWithWhite:250.0/255.0 alpha:1.0] set];
        CGContextFillRect(ctx, CGRectMake(self.paddingLeftRight + 1, cb.size.height-1, cb.size.width - 2*(self.paddingLeftRight + 1), 1));
    }
     
    [self drawCellContent:b];
}

@end

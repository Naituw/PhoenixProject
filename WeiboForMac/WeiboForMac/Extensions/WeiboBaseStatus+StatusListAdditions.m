//
//  WeiboBaseStatus+StatusListAdditions.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-7-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus+StatusListAdditions.h"
#import "WeiboBaseStatus+StatusCellAdditions.h"
#import "WTStatusTableView.h"
#import "WMStatusImageContentView.h"
#import "TUIStringDrawing.h"
#import "WeiboLayoutCache.h"
#import "WeiboMac2Window.h"
#import "WUIView.h"
#import "WMUserPreferences.h"

@implementation WeiboBaseStatus (StatusListAdditions)

- (CGFloat)textHeightInTableView:(WTStatusTableView *)tableView
{    
    CGFloat contentWidth = [self textWidthInCellWithWidth:tableView.bounds.size.width];
    
    TUITextRenderer * renderer = tableView.textRenderer;
        
    // Using a attributedString that only has font attributed here
    // to speed up calculation.
    CGFloat fontsize = [[WMUserPreferences sharedPreferences] fontSize];

    TUIAttributedString * stringForHeightCalculation = [TUIAttributedString stringWithString:self.displayText];
    stringForHeightCalculation.font = [TUIFont fontWithName:@"HelveticaNeue-Light" size:fontsize];
    [renderer setAttributedString:stringForHeightCalculation];
    CGFloat height = [renderer sizeConstrainedToWidth:contentWidth].height;

    return height;
}

- (CGFloat)heightInTableView:(WTStatusTableView *)tableView
{
    NSString * identifier = tableView.windowIdentifier;
    NSAssert(identifier != nil, @"window identifier should NOT be nil");
    
    WeiboLayoutCache * layoutCache = [self layoutCacheWithIdentifier:identifier];

    WMUserPreferences * preferences = [WMUserPreferences sharedPreferences];
    
    BOOL showThumb = [preferences showsThumbImage];
    BOOL placeThumbOnSide = [self placeThumbImageOnSideOfCell];
    CGFloat fontsize = [preferences fontSize];
    
#define LayoutCacheValid(lc) lc.width == tableView.bounds.size.width && \
    lc.showThumb == showThumb &&\
    lc.fontSize == fontsize &&\
    lc.placeThumbOnSide == placeThumbOnSide
    
    if (LayoutCacheValid(layoutCache))
    {
        return layoutCache.height;
    }
    
    if (tableView.bounds.size.width == 0)
    {
        return 0;
    }
    
    layoutCache.textFrame = CGRectZero;
    layoutCache.quotedTextFrame = CGRectZero;
    layoutCache.quoteLineFrame = CGRectZero;
    layoutCache.imageContentViewFrame = CGRectZero;
    
    CGFloat cellWidth = tableView.bounds.size.width;
    
    CGFloat baseY = 32, baseX = 70;
    CGFloat thumbHeight = 60, thumbWidth = 71;
    CGFloat imageContentViewMaxWidth = 0;
    
    {
        layoutCache.textHeight = [self textHeightInTableView:tableView];
        
        CGFloat textWidth = [self textWidthInCellWithWidth:cellWidth];
        CGFloat textHeight = layoutCache.textHeight;
        CGRect contentFrame = CGRectMake(baseX,  baseY, textWidth, textHeight);
        
        layoutCache.textFrame = contentFrame;
        
        baseY += textHeight;
        baseY += 10; // span
        
        imageContentViewMaxWidth = textWidth;
    }
    
    if (self.quotedBaseStatus)
    {
        layoutCache.textHeightOfQuotedStatus = [self.quotedBaseStatus textHeightInTableView:tableView];
        
        CGFloat textWidth = [self.quotedBaseStatus textWidthInCellWithWidth:cellWidth];
        CGFloat textHeight = layoutCache.textHeightOfQuotedStatus;
                        
        layoutCache.quoteLineFrame = CGRectMake(baseX, baseY, 5, textHeight);
        layoutCache.quotedTextFrame = CGRectMake(baseX + 12, baseY, textWidth, textHeight);
        
        imageContentViewMaxWidth = textWidth;
    }
    
    if (showThumb && (self.thumbnailPic || self.quotedBaseStatus.thumbnailPic))
    {
        if (placeThumbOnSide)
        {
            CGFloat thumbY = layoutCache.textFrame.origin.y;
            
            if (self.quotedBaseStatus)
            {
                thumbY = layoutCache.quotedTextFrame.origin.y;
            }
            
            layoutCache.imageContentViewFrame = CGRectMake(cellWidth - thumbWidth, thumbY, thumbWidth, thumbHeight);
        }
        else
        {
            WeiboBaseStatus * status = self;
            CGRect textFrame = layoutCache.textFrame;
            
            if (status.quotedBaseStatus)
            {
                status = status.quotedBaseStatus;
                textFrame = layoutCache.quotedTextFrame;
            }
            
            CGSize imageContentViewSize = [WMStatusImageContentView sizeWithImageCount:status.pics.count constrainedToWidth:imageContentViewMaxWidth];
            CGRect imageContentViewRect = CGRectZero;
            imageContentViewRect.size = imageContentViewSize;
            imageContentViewRect.origin = CGPointMake(textFrame.origin.x, textFrame.origin.y + textFrame.size.height + 10);
            
            layoutCache.imageContentViewFrame = imageContentViewRect;
        }
    }

#define MAXY(rect) (rect.origin.y + rect.size.height)
    
    CGFloat maxY = MAX(MAXY(layoutCache.textFrame),MAXY(layoutCache.quotedTextFrame));
    maxY = MAX(maxY, MAXY(layoutCache.imageContentViewFrame));
    
    CGFloat height = maxY + 10;
    
    CGFloat minimalHeight = 72.0;
    
    if (height < minimalHeight) height = minimalHeight;
    
    layoutCache.width = cellWidth;
    layoutCache.height = height;
    layoutCache.fontSize = fontsize;
    layoutCache.showThumb = showThumb;
    layoutCache.placeThumbOnSide = placeThumbOnSide;
    
    return height;
}

@end

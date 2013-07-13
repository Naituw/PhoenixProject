//
//  WeiboBaseStatus+StatusCellAdditions.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-25.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus+StatusCellAdditions.h"
#import "WTActiveTextRanges.h"
#import "ABActiveRange.h"
#import "WeiboUser.h"
#import "WMUserPreferences.h"
#import "TUIKit.h"

@implementation WeiboBaseStatus (StatusCellAdditions)

- (BOOL)placeThumbImageOnSideOfCell
{
    BOOL rightSide = [[WMUserPreferences sharedPreferences] placeThumbImageOnSideOfCell];
    
    if (!rightSide)
    {
        return NO;
    }
    else
    {
        if (self.pics.count > 1 || self.quotedBaseStatus.pics.count > 1)
        {
            return NO;
        }
        return YES;
    }
}

- (CGFloat)textWidthInCellWithWidth:(CGFloat)cellWidth
{
    CGFloat contentWidth = cellWidth - 80;
    
    BOOL showThumb = self.thumbnailPic && [[WMUserPreferences sharedPreferences] showsThumbImage];
    
    if(showThumb && [self placeThumbImageOnSideOfCell])
    {
        contentWidth -= 66;
    }
    
    if (self.quoted)
    {
        // have a vertical line on left side.
        contentWidth -= 12;
    }
    
    return contentWidth;
}

- (TUIAttributedString *)attributedTextForString:(NSString *)string
{
    if (!string) return nil;
    
    TUIAttributedString * display = [TUIAttributedString stringWithString:string];
    display.color = [TUIColor colorWithWhite:0.25 alpha:1.0];
    
    for (ABFlavoredRange * range in self.activeRanges.activeRanges)
    {
        TUIColor * fontColor = nil;
        if (range.rangeFlavor == ABActiveTextRangeFlavorTwitterHashtag)
        {
            fontColor = HASHTAG_COLOR;
        }
        else
        {
            fontColor = HIGHLIGHTED_COLOR;
        }
        [display setColor:fontColor inRange:range.rangeValue];
    }
    
    CGFloat fontsize = [[WMUserPreferences sharedPreferences] fontSize];
    display.font = [TUIFont fontWithName:@"HelveticaNeue-Light" size:fontsize];
    
    return display;
}

- (TUIAttributedString *)attributedText
{
    return [self attributedTextForString:self.displayText];
}

@end

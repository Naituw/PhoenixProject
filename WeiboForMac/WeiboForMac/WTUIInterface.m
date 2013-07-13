//
//  WTUIInterface.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIInterface.h"
#import <AppKit/NSFont.h>


@implementation TUIColor (UIColorSystemColors)

+ (TUIColor *)groupTableViewBackgroundColor
{
    return [TUIColor lightGrayColor];    // this is currently not likely to be correct, please fix!
}

@end


@implementation TUIFont (UIFontSystemFonts)

+ (CGFloat)systemFontSize
{
    return [NSFont systemFontSize];
}

+ (CGFloat)smallSystemFontSize
{
    return [NSFont smallSystemFontSize];
}

+ (CGFloat)labelFontSize
{
    return [NSFont labelFontSize];
}

+ (CGFloat)buttonFontSize
{
    return [NSFont systemFontSizeForControlSize:NSRegularControlSize];
}

@end

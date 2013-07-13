//
//  TUIColor+WMAdditions.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIColor+WMAdditions.h"

@implementation TUIColor (WMAdditions)

TUIColor * TUIRGBColor(CGFloat r, CGFloat g, CGFloat b)
{
    return TUIRGBAColor(r, g, b, 1.0);
}

TUIColor * TUIRGBAColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [TUIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

TUIColor * TUIHEXColor(NSInteger hex)
{
    return TUIHEXAColor(hex, 1.0);
}
TUIColor * TUIHEXAColor(NSInteger hex, CGFloat alpha)
{
    CGFloat r = ((float)((hex & 0xFF0000) >> 16)),
            g = ((float)((hex & 0xFF00) >> 8)),
            b = ((float)(hex & 0xFF));
    
    return TUIRGBAColor(r, g, b, alpha);
}

@end

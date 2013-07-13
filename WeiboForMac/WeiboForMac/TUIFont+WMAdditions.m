//
//  TUIFont+WMAdditions.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUIFont+WMAdditions.h"

@implementation TUIFont (WMAdditions)

+ (TUIFont *)defaultFontOfSize:(CGFloat)size
{
    return [TUIFont fontWithName:@"HelveticaNeue" size:size];
}
+ (TUIFont *)lightDefaultFontOfSize:(CGFloat)size
{
    return [TUIFont fontWithName:@"HelveticaNeue-Light" size:size];
}
+ (TUIFont *)boldDefaultFontOfSize:(CGFloat)size
{
    return [TUIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

@end

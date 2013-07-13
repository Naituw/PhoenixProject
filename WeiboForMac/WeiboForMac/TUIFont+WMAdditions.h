//
//  TUIFont+WMAdditions.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUIFont.h"

@interface TUIFont (WMAdditions)

+ (TUIFont *)defaultFontOfSize:(CGFloat)size;
+ (TUIFont *)lightDefaultFontOfSize:(CGFloat)size;
+ (TUIFont *)boldDefaultFontOfSize:(CGFloat)size;

@end

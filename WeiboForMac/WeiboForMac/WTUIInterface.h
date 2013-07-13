//
//  WTUIInterface.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIColor.h"
#import "TUIFont.h"


typedef enum {
    UIBarStyleDefault = 0,
    UIBarStyleBlack = 1,
    UIBarStyleBlackOpaque = 1, // Deprecated
    UIBarStyleBlackTranslucent = 2 // Deprecated
} UIBarStyle;


@interface TUIColor (UIColorSystemColors)
+ (TUIColor *)groupTableViewBackgroundColor;
@end


@interface TUIFont (UIFontSystemFonts)
+ (CGFloat)systemFontSize;
+ (CGFloat)smallSystemFontSize;
+ (CGFloat)labelFontSize;
+ (CGFloat)buttonFontSize;
@end

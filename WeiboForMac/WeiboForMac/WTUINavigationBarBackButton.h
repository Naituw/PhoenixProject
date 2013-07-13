//
//  WTUINavigationBarBackButton.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-17.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIKit.h"
#import "WTUIStaticTextRenderer.h"

@interface WTUINavigationBarBackButton : TUIButton {
    WTUIStaticTextRenderer * title;
}

- (id)initWithString:(NSString *)string;
- (id)initWithString:(NSString *)string fontSize:(CGFloat)fontSize;

@end

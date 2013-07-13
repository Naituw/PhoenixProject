//
//  WTUILableView.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-11.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIKit.h"
#import "WTUIStaticTextRenderer.h"

@interface WTUILableView : WUIView {
    WTUIStaticTextRenderer * text;
}

- (id)initWithString:(NSString *)string;
- (id)initWithString:(NSString *)string fontSize:(CGFloat)fontSize;

- (CGFloat) textPositionX;

@end

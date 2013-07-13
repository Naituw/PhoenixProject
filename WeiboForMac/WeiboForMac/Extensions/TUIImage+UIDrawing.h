//
//  TUIImage+UIDrawing.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-6-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIImage.h"

@interface TUIImage (UIDrawing)


+ (TUIImage *)macAvatarFromImage:(TUIImage *)image contentScale:(CGFloat)scale;
+ (TUIImage *)macThumbFromNSImage:(NSImage *)image;

@end

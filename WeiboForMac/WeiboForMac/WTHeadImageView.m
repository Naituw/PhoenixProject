//
//  WTHeadImageView.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-4.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTHeadImageView.h"
#import "TUIImage.h"
#import "TUIImage+UIDrawing.h"

@implementation WTHeadImageView

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)prepare
{

}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [[self superview] mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    [[self superview] mouseUp:theEvent];
}

- (TUIImage *)defalutPlaceholder
{
    CGFloat scale = self.layer.contentsScale;
    static TUIImage * defalutImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TUIImage * empty = [TUIImage imageNamed:@"status_cell_avatar_empty.png"];
        defalutImage = [[TUIImage macAvatarFromImage:empty contentScale:scale] retain];
    });
    return defalutImage;
}

@end

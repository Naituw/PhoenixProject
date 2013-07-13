//
//  WTThumbPicView.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTThumbPicView.h"
#import "WTPopoverViewController.h"
#import "WMMediaViewerController.h"
#import "TUIKit.h"
#import "TUIImage+UIDrawing.h"
#import "WTEventHandler.h"

#define POPOVER_OFFSET 10.0f

@interface WTThumbPicView () <WMMediaLoaderSourceView>

@end

@implementation WTThumbPicView

- (void)dealloc
{
    [_picture release], _picture = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (WeiboPicture *)mediaObject
{
    return self.picture;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self superview] mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    if (![self eventInside:theEvent])
    {
        return;
    }
    
    if ([self.picture.middleImage hasSuffix:@".gif"])
    {
        [WTEventHandler openURL:self.picture.originalImage];
    }
    else
    {
        WMMediaViewerController * controller = [WMMediaViewerController controllerForMedia:self.picture sourceView:self sourcePoint:[self localPointForEvent:theEvent]];
        [controller startMediaLoading];
    }
}

- (void)prepare
{
    [self setImage:nil];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.alpha = 0.8;
    [super mouseEntered:theEvent];
}
- (void)mouseExited:(NSEvent *)theEvent
{
    self.alpha = 1.0;
    [super mouseExited:theEvent];
}

- (void)drawRect:(CGRect)drect{
    TUIImage * theImage = [self image];
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGContextClearRect(ctx,drect);
    
    CGRect rect = drect;
    rect.size.width = 60;
    
    CGSize imageSize = [theImage size];
    CGRect imageRect = CGRectZero;
    imageRect.size = imageSize;
    
    if (theImage)
    {
        CGImageRef subimageRef = CGImageCreateWithImageInRect(theImage.CGImage, imageRect);
        CGContextDrawImage(ctx, rect, subimageRef);
        CGImageRelease(subimageRef);
    }
}

- (TUIImage *)defalutPlaceholder
{
    static TUIImage * defalutImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSImage * thumb = [NSImage imageNamed:@"status_cell_thumbnail_empty"];
        defalutImage = [[TUIImage macThumbFromNSImage:thumb] retain];
    });
    return defalutImage;
}

- (void)setPicture:(WeiboPicture *)picture
{
    if (_picture != picture)
    {
        SetRetainedIvar(_picture, picture);
        
        [self setImageWithURL:[NSURL URLWithString:self.picture.thumbnailImage] drawingStyle:WMWebImageDrawingStyleMacThumb];
    }
}

@end

//
//  WTWebImageView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTWebImageView.h"
#import "TUIKit.h"
#import "TUIImage+UIDrawing.h"

@implementation WTWebImageView
@synthesize imageURL, image = _image, loaded = _loaded, loading = _loading;

- (void)dealloc
{
    [_image release], _image = nil;
    [imageURL release], imageURL = nil;
    [super dealloc];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(TUIImage *)placeholder
{
    [self setImageWithURL:url style:nil styler:nil];
}
- (void)setImageFromCacheWithURL:(NSURL *)url  style:(NSString *)style
{
    if (imageURL)
    {
        self.imageURL = nil;
    }
    
    if (!url)
    {
        self.imageURL = nil;
        return;
    }
    else
    {
        self.imageURL = url;
    }
    
    self.image = nil;
    
    __block BOOL hit = NO;
    [[EGOImageLoader sharedImageLoader] loadImageFromCacheForURL:url style:style completion:^(NSData *imageData, NSURL *imageURL, NSError *error) {
        self.image = [TUIImage imageWithData:imageData];
        hit = YES;
    }];
    
    self.loaded = hit;
    
    if (!self.loaded)
    {
        self.image = self.defalutPlaceholder;
    }
}
- (void)setImageWithURL:(NSURL *)url style:(NSString *)style styler:(NSData* (^)(NSData* imageData))styler
{
    if (self.loaded || self.loading)
    {
        return;
    }
    
    if(imageURL)
    {
		self.imageURL = nil;
	}
    
    if(!url)
    {
		self.imageURL = nil;
		return;
	}
    else
    {
		self.imageURL = url;
	}
    
    self.image = [self defalutPlaceholder];

    self.loading = YES;
    [[EGOImageLoader sharedImageLoader] loadImageForURL:url style:style styler:styler completion:^(NSData *imageData, NSURL *imageURL, NSError *error) {
        if (imageData)
        {
            self.image = [TUIImage imageWithData:imageData];
            self.loaded = YES;
        }
        self.loading = NO;
    }];
}
- (void)cancelCurrentImageLoad
{
    if (!self.imageURL)
    {
        return;
    }

    [[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
}


- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    if (self.image)
    {
        CGRect fromRect = b;
        fromRect.size = [self.image size];
        
        CGImageRef subimageRef = CGImageCreateWithImageInRect(self.image.CGImage, fromRect);
        CGContextDrawImage(ctx, b, subimageRef);
        CGImageRelease(subimageRef);
    }
}

- (void)setImage:(TUIImage *)image
{
    if (_image != image)
    {
        SetAtomicRetainedIvar(_image, image);
        
        [self setNeedsDisplay];
    }
}

- (TUIImage *)defalutPlaceholder
{
    return nil;
}

@end

@implementation WTWebImageView (WMAdditions)

- (void)setImageWithURL:(NSURL *)url drawingStyle:(WMWebImageDrawingStyle)drawingStyle
{
    CGFloat scale = self.layer.contentsScale;
    
    switch (drawingStyle)
    {
        case WMWebImageDrawingStyleMacAvatar:
        {
            [self setImageWithURL:url style:@"cell-avatar-style" styler:^NSData *(NSData *imageData) {
                TUIImage * i = [TUIImage imageWithData:imageData];
                i = [TUIImage macAvatarFromImage:i contentScale:scale];
                return TUIImagePNGRepresentation(i);
            }];
            break;
        }
        case WMWebImageDrawingStyleMacThumb:
        {
            [self setImageWithURL:url style:@"cell-thumb-style" styler:^NSData *(NSData *imageData) {
                NSImage * nsimage = [[[NSImage alloc] initWithData:imageData] autorelease];
                TUIImage * i = [TUIImage macThumbFromNSImage:nsimage];
                return TUIImagePNGRepresentation(i);
            }];
            break;
        }
        default:
        {
            [self setImageWithURL:url];
            break;
        }
    }
}

@end
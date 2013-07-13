//
//  TUIImage+UIPrivate.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIImage+UIPrivate.h"
#import "TUIImage.h"
#import "TUIColor.h"
#import "UIGraphics.h"
#import <AppKit/NSImage.h>

NSMutableDictionary *imageCache = nil;

@implementation TUIImage (UIPrivate)

+ (void)load
{
    imageCache = [[NSMutableDictionary alloc] init];
}

+ (NSString *)_macPathForFile:(NSString *)path
{
    NSString *home = [path stringByDeletingLastPathComponent];
    NSString *filename = [path lastPathComponent];
    NSString *extension = [filename pathExtension];
    NSString *bareFilename = [filename stringByDeletingPathExtension];
    
    return [home stringByAppendingPathComponent:[[bareFilename stringByAppendingString:@"@mac"] stringByAppendingPathExtension:extension]];
}

+ (NSString *)_pathForFile:(NSString *)path
{
    NSString *macPath = [self _macPathForFile:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:macPath]) {
        return macPath;
    } else {
        return path;
    }
}

+ (void)_cacheImage:(TUIImage *)image forName:(NSString *)name
{
    if (image && name) {
        [imageCache setObject:image forKey:name];
    }
}

+ (TUIImage *)_cachedImageForName:(NSString *)name
{
    return [imageCache objectForKey:name];
}

+ (NSString *)_nameForCachedImage:(TUIImage *)image
{
    __block NSString * result = nil;
    [imageCache enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ( obj == image ) {
            result = [key copy];
            *stop = YES;
        }
    }];
    return [result autorelease];
}

+ (TUIImage *)_imageFromNSImage:(NSImage *)ns
{
    // if the NSImage isn't named, we can't optimize
    if ([[ns name] length] == 0)
        return [self imageWithNSImage:ns];
    
    // if it's named, we can cache a UIImage instance for it
    TUIImage *cached = [self _cachedImageForName:[ns name]];
    if (cached == nil) {
        cached = [self imageWithNSImage:ns];
        [self _cacheImage:cached forName:[ns name]];
    }
    
    return cached;
}

+ (TUIImage *)_frameworkImageWithName:(NSString *)name leftCapWidth:(NSUInteger)leftCapWidth topCapHeight:(NSUInteger)topCapHeight
{
    TUIImage *image = [self _cachedImageForName:name];
    
    if (!image) {
        NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"org.chameleonproject.UIKit"];
        NSString *frameworkFile = [[frameworkBundle resourcePath] stringByAppendingPathComponent:name];
        image = [[self imageWithData:[NSData dataWithContentsOfFile:frameworkFile]] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
        [self _cacheImage:image forName:name];
    }
    
    return image;
}

+ (TUIImage *)_backButtonImage
{
    return [self _frameworkImageWithName:@"<UINavigationBar> back.png" leftCapWidth:18 topCapHeight:0];
}

+ (TUIImage *)_highlightedBackButtonImage
{
    return [self _frameworkImageWithName:@"<UINavigationBar> back-highlighted.png" leftCapWidth:18 topCapHeight:0];
}

+ (TUIImage *)_toolbarButtonImage
{
    return [self _frameworkImageWithName:@"<UIToolbar> button.png" leftCapWidth:6 topCapHeight:0];
}

+ (TUIImage *)_highlightedToolbarButtonImage
{
    return [self _frameworkImageWithName:@"<UIToolbar> button-highlighted.png" leftCapWidth:6 topCapHeight:0];
}

+ (TUIImage *)_leftPopoverArrowImage
{
    return [self _frameworkImageWithName:@"<UIPopoverView> arrow-left.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_rightPopoverArrowImage
{
    return [self _frameworkImageWithName:@"<UIPopoverView> arrow-right.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_topPopoverArrowImage
{
    return [self _frameworkImageWithName:@"<UIPopoverView> arrow-top.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_bottomPopoverArrowImage
{
    return [self _frameworkImageWithName:@"<UIPopoverView> arrow-bottom.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_popoverBackgroundImage
{
    return [self _frameworkImageWithName:@"<UIPopoverView> background.png" leftCapWidth:23 topCapHeight:23];
}

+ (TUIImage *)_roundedRectButtonImage
{
    return [self _frameworkImageWithName:@"<UIRoundedRectButton> normal.png" leftCapWidth:12 topCapHeight:9];
}

+ (TUIImage *)_highlightedRoundedRectButtonImage
{
    return [self _frameworkImageWithName:@"<UIRoundedRectButton> highlighted.png" leftCapWidth:12 topCapHeight:9];
}

+ (TUIImage *)_windowResizeGrabberImage
{
    return [self _frameworkImageWithName:@"<UIScreen> grabber.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_buttonBarSystemItemAdd
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> add.png" leftCapWidth:0 topCapHeight:0];
}

+ (TUIImage *)_buttonBarSystemItemReply
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> reply.png" leftCapWidth:0 topCapHeight:0];
}

- (TUIImage *)_toolbarImage
{
    // NOTE.. I don't know where to put this, really, but it seems like the real UIKit reduces image size by 75% if they are too
    // big for a toolbar. That seems funky, but I guess here is as good a place as any to do that? I don't really know...
    
    CGSize imageSize = self.size;
    CGSize size = CGSizeZero;
    
    if (imageSize.width > 24 || imageSize.height > 24) {
        size.height = imageSize.height * 0.75f;
        size.width = imageSize.width / imageSize.height * size.height;
    } else {
        size = imageSize;
    }
    
    CGRect rect = CGRectMake(0,0,size.width,size.height);
    
    UIGraphicsBeginImageContext(size);
    [[TUIColor colorWithRed:101/255.f green:104/255.f blue:121/255.f alpha:1] setFill];
    UIRectFill(rect);
    [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1];
    TUIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (TUIImage *)_tabBarBackgroundImage
{
    return [self _frameworkImageWithName:@"<UITabBar> background.png" leftCapWidth:6 topCapHeight:0];
}

+ (TUIImage *)_tabBarItemImage
{
    return [self _frameworkImageWithName:@"<UITabBar> item.png" leftCapWidth:8 topCapHeight:0];
}

@end


NSImage *_NSImageCreateSubimage(NSImage *theImage, CGRect rect)
{
    // flip coordinates around...
    rect.origin.y = (theImage.size.height) - rect.size.height - rect.origin.y;
    NSImage *destinationImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(rect.size)];
    [destinationImage lockFocus];
    [theImage drawAtPoint:NSZeroPoint fromRect:NSRectFromCGRect(rect) operation:NSCompositeCopy fraction:1];
    [destinationImage unlockFocus];
    return destinationImage;
}


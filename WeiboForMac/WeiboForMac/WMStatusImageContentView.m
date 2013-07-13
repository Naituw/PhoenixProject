//
//  WMStatusImageContentView.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMStatusImageContentView.h"
#import "WeiboPicture.h"
#import "WMThumbnailImageView.h"
#import "TUIImage+UIDrawing.h"

@interface WMStatusImageContentView ()

@property (nonatomic, retain) NSMutableArray * imageViews;

@end

@implementation WMStatusImageContentView

- (void)dealloc
{
    [_pictures release], _pictures = nil;
    [_imageViews release], _imageViews = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [TUIColor clearColor];
    }
    return self;
}

+ (CGFloat)defaultSpacing
{
    return 1;
}
+ (CGSize)defaultItemSize
{
    return CGSizeMake(60, 60);
}
+ (NSInteger)maximumItemsPerRow
{
    return 9;
}

+ (NSInteger)itemsPerRowConstrainedToWidth:(CGFloat)maxWidth
{
    CGSize itemSize = [self defaultItemSize];
    NSInteger itemsPerRow = [self maximumItemsPerRow];
    CGFloat spacing = [self defaultSpacing];
    
    while (itemsPerRow > 1)
    {
        CGFloat width = itemsPerRow * itemSize.width + (itemsPerRow - 1) * spacing;
        
        if (width <= maxWidth)
        {
            break;
        }
        
        itemsPerRow--;
    }

    return itemsPerRow;
}

+ (CGSize)sizeWithImageCount:(NSInteger)count constrainedToWidth:(CGFloat)maxWidth
{
    CGSize itemSize = [self defaultItemSize];
    
    if (count == 1)
    {
        return itemSize;
    }
    
    CGFloat spacing = [self defaultSpacing];
    
    NSInteger itemsPerRow = [self itemsPerRowConstrainedToWidth:maxWidth];
    
    NSInteger rows = (NSInteger)ceil((double)count / (double)itemsPerRow);
    
    CGFloat width = itemsPerRow * itemSize.width + (itemsPerRow - 1) * spacing;
    CGFloat height = rows * itemSize.height + (rows - 1) * spacing;
    
    if (count <= itemsPerRow)
    {
        width = count * itemSize.width + (count - 1) * spacing;
    }
    
    return CGSizeMake(width, height);
}

- (WMThumbnailImageView *)imageViewForPicture:(WeiboPicture *)picture
{
    for (WMThumbnailImageView * view in self.imageViews)
    {
        if ([view.picture isEqual:picture])
        {
            return view;
        }
    }
    
    WMThumbnailImageView * imageView = [[WMThumbnailImageView alloc] init];
    
    [imageView setBackgroundColor:[TUIColor clearColor]];
    [imageView setPicture:picture];
    
    return [imageView autorelease];
}

- (CGRect)frameForImageViewAtIndex:(NSInteger)index
{
    NSInteger itemsPerRow = [[self class] itemsPerRowConstrainedToWidth:self.width];
    
    NSInteger row = (NSInteger)ceil((double)(index + 1) / (double)itemsPerRow);
    NSInteger column = (index + 1) - (row - 1) * itemsPerRow;
    
    CGFloat spacing = [[self class] defaultSpacing];
    CGSize itemSize = [[self class] defaultItemSize];
    
    CGFloat left = (column - 1) * (spacing + itemSize.width);
    CGFloat top = (row - 1) * (spacing + itemSize.height);
    
    return CGRectMake(left, self.height - top - itemSize.height, itemSize.width, itemSize.height);
}

- (void)reloadImageViews
{
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray * newImageViews = [NSMutableArray array];
    
    NSInteger index = 0;
    
    for (WeiboPicture * picture in self.pictures)
    {
        WMThumbnailImageView * imageView = [self imageViewForPicture:picture];
        
        [self addSubview:imageView];
        
        [imageView setFrame:[self frameForImageViewAtIndex:index]];
        
        [newImageViews addObject:imageView];
        
        index++;
    }
    
    self.imageViews = newImageViews;
}

- (void)cancelCurrentImageLoad
{
    [self.imageViews makeObjectsPerformSelector:@selector(cancelCurrentImageLoad)];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint location = [self localPointForEvent:theEvent];
    
    TUIView * target = [self hitTest:location withEvent:theEvent];
    
    if (target == self) // not in a subview
    {
        [self.superview mouseDown:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.superview mouseUp:theEvent];
}

@end

//
//  WMStatusImageContentView.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIView.h"

@interface WMStatusImageContentView : WUIView

+ (CGFloat)defaultSpacing;
+ (CGSize)defaultItemSize;
+ (NSInteger)maximumItemsPerRow;
+ (CGSize)sizeWithImageCount:(NSInteger)count constrainedToWidth:(CGFloat)width;

@property (nonatomic, retain) NSArray * pictures; // Array of WeiboPicture object

- (void)reloadImageViews;
- (void)cancelCurrentImageLoad;

@end

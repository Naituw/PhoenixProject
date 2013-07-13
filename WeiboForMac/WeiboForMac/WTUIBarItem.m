//
//  WTUIBarItem.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIBarItem.h"
#import "TUIImage.h"

@implementation WTUIBarItem
@synthesize enabled=_enabled, image=_image, imageInsets=_imageInsets, title=_title, tag=_tag;

- (id)init
{
    if ((self = [super init])) {
        self.enabled = YES;
        self.imageInsets = TUIEdgeInsetsZero;
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [_title release];
    [super dealloc];
}

@end

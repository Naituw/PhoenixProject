//
//  WTThumbPicView.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTWebImageView.h"
#import "WeiboPicture.h"

@interface WTThumbPicView : WTWebImageView
{
    BOOL isHovering;
}

- (void)prepare;

@property (nonatomic, retain) WeiboPicture * picture;

@end

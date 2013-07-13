//
//  WTGeometry.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-11.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WTGeometry.h"
#import "TUIGeometry.h"

CGRect CGRectGetCenterRect(CGRect rect, CGSize size)
{
	CGFloat x = (rect.size.width - size.width) / 2.0f;
	CGFloat y = (rect.size.height - size.height) / 2.0f;
	
	return TUIEdgeInsetsInsetRect(rect, TUIEdgeInsetsMake(y, x, y, x));
}

CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}
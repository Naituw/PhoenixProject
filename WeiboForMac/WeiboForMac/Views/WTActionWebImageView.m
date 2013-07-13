//
//  WTActionWebImageView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTActionWebImageView.h"

@implementation WTActionWebImageView
@synthesize target, action;

- (void)mouseUp:(NSEvent *)theEvent{
    [target performSelector:action];
}

@end

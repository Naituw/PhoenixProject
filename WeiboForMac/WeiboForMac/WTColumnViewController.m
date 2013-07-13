//
//  WTColumnViewController.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-8.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTColumnViewController.h"

@interface WTColumnViewController ()
@end

@implementation WTColumnViewController

- (void)dealloc{
    [super dealloc];
}
- (id)init
{
    if (self = [super init]) {
        [self navigationBar].delegate = self;
    }
    return self;
}

- (BOOL)isRoot:(WTUIViewController *)controller{
    return NO;
}

@end

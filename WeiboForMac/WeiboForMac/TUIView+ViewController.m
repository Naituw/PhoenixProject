//
//  TUIView+ViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUIView+ViewController.h"

@implementation TUIView (ViewController)

- (TUIViewController *)firstAvailableViewController
{
    id nextResponder = self.nextResponder;

    if ([nextResponder isKindOfClass:[TUIViewController class]])
    {
        return nextResponder;
    }
    else if ([nextResponder isKindOfClass:[TUIView class]])
    {
        return [nextResponder firstAvailableViewController];
    }
    else
    {
        return nil;
    }
}

@end

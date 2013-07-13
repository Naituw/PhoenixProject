//
//  WMSatelliteWindow.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboMac2Window.h"
#import "WTUIViewController.h"
#import "WMColumnViewController.h"

@interface WMSatelliteWindow : WeiboMac2Window

- (id)initWithViewController:(WTUIViewController *)viewController oldFrameOnScreen:(CGRect)oldFrame;

@property (retain, nonatomic) WMColumnViewController * columnViewController;

@end

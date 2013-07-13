//
//  WMMediaViewerWindow.h
//  WeiboForMac
//
//  Created by Wutian on 13-6-1.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WTImageViewer.h"
#import "WMMediaViewerController.h"

@interface WMMediaViewerWindow : WTImageViewer

@property (nonatomic, assign) WMMediaViewerController * viewerController;
@property (nonatomic, assign) BOOL orderingOut;

+ (NSArray *)mediaViewerWindows;

@end

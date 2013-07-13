//
//  WMMediaViewerController.h
//  WeiboForMac
//
//  Created by Wutian on 13-6-1.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboPicture.h"

// 目前只支持图片查看，因此Media都代表 WeiboPicture对象

@protocol WMMediaLoaderSourceView <NSObject>
@required
- (WeiboPicture *)mediaObject;
@end

@interface WMMediaViewerController : NSWindowController

+ (id)controllerForMedia:(WeiboPicture *)media sourceView:(TUIView<WMMediaLoaderSourceView> *)sourceView sourcePoint:(CGPoint)sourcePoint;

- (id)initWithMedia:(WeiboPicture *)media sourceView:(TUIView<WMMediaLoaderSourceView> *)sourceView sourcePoint:(CGPoint)sourcePoint;

@property (nonatomic, retain) TUIView<WMMediaLoaderSourceView> * sourceView;
@property (nonatomic, assign) CGPoint sourcePoint;

@property (nonatomic, retain) WeiboPicture * media;

- (void)startMediaLoading;
- (BOOL)loadingFinished;

- (void)makeNextViewerKeyWindow;

@end

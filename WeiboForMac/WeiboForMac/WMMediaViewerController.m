//
//  WMMediaViewerController.m
//  WeiboForMac
//
//  Created by Wutian on 13-6-1.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMMediaViewerController.h"
#import "WMMediaViewerWindow.h"
#import "WMMediaLoaderView.h"

@interface WMMediaViewerController () <ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    struct {
        unsigned int loadingStarted: 1;
        unsigned int loadingFinished: 1;
        unsigned int sourceViewMode: 1;
    } _flags;
}

@property (nonatomic, retain) WMMediaLoaderView * loaderView;
@property (nonatomic, readonly) WMMediaViewerWindow * viewerWindow;

@property (nonatomic, retain) WTImageRequest * currentRequest;

@property (nonatomic, assign) NSTimeInterval loadingFinishTime;

@end

@implementation WMMediaViewerController

- (void)dealloc
{
    [_currentRequest clearDelegatesAndCancel];
    [_currentRequest release];
    
    [_loaderView removeFromSuperview];
    [_loaderView release], _loaderView = nil;
    [_media release], _media = nil;
    [_sourceView release], _sourceView = nil;
    [super dealloc];
}

+ (NSArray *)existingViewerControllers
{
    NSArray * viewerWindows = [WMMediaViewerWindow mediaViewerWindows];
    NSMutableArray * controllers = [NSMutableArray array];
    
    for (WMMediaViewerWindow * window in viewerWindows)
    {
        if (!window.orderingOut && window.viewerController)
        {
            [controllers addObject:window.viewerController];
        }
    }
    
    return controllers;
}

+ (id)controllerForMedia:(WeiboPicture *)media sourceView:(TUIView<WMMediaLoaderSourceView> *)sourceView sourcePoint:(CGPoint)sourcePoint;
{
    NSArray * controllers = [self existingViewerControllers];
    
    for (WMMediaViewerController * controller in controllers)
    {
        if ([controller.media isEqual:media])
        {
            return controller;
        }
    }
    
    return [[self alloc] initWithMedia:media sourceView:sourceView sourcePoint:sourcePoint];
}

- (id)init
{
    WMMediaViewerWindow * window = [[[WMMediaViewerWindow alloc] init] autorelease];
    if (self = [super initWithWindow:window])
    {
        window.viewerController = self;
        
        self.loaderView = [[[WMMediaLoaderView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)] autorelease];
    }
    
    return self;
}

- (id)initWithMedia:(WeiboPicture *)media sourceView:(TUIView<WMMediaLoaderSourceView> *)sourceView sourcePoint:(CGPoint)sourcePoint
{
    if (self = [self init])
    {
        self.sourceView = sourceView;
        self.media = media;
        self.sourcePoint = sourcePoint;
        
        if (sourceView)
        {
            _flags.sourceViewMode = YES;
        }
    }
    return self;
}

- (WMMediaViewerWindow *)viewerWindow
{
    if ([self.window isKindOfClass:[WMMediaViewerWindow class]])
    {
        return (WMMediaViewerWindow *)self.window;
    }
    return nil;
}

- (void)makeNextViewerKeyWindow
{
    NSMutableArray * controllers = [[[[self class] existingViewerControllers] mutableCopy] autorelease];
    
    [controllers sortUsingComparator:^NSComparisonResult(WMMediaViewerController * obj1, WMMediaViewerController * obj2) {
        if (obj1.loadingFinishTime > obj2.loadingFinishTime)
        {
            return NSOrderedDescending;
        }
        else if (obj1.loadingFinishTime < obj2.loadingFinishTime)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    for (NSInteger index = controllers.count - 1; index >= 0; index--)
    {
        WMMediaViewerController * controller = controllers[index];
        
        if (controller != self &&
            controller.loadingFinished)
        {
            [controller.window makeKeyAndOrderFront:self];
            break;
        }
    }
}

- (void)close
{    
    [self autorelease];
    [super close];
}

- (BOOL)loadingFinished
{
    return _flags.loadingFinished;
}

- (void)startMediaLoading
{
    if (_flags.loadingStarted)
    {
        if (_flags.loadingFinished)
        {
            [self.window makeKeyAndOrderFront:self];
        }
        
        return;
    }
    
    if (_flags.sourceViewMode)
    {
        [self setLoadingFinishTime:0];
        
        [self _loadImage];
        [self _updateLoaderWithProgress:0.0];
    }
    else
    {
        // Use the old fashion way
        
        _flags.loadingStarted = YES;
        _flags.loadingFinished = YES;
        
        [self.viewerWindow setPicture:self.media];
        [self.viewerWindow viewImageAtUrl:self.media.middleImage];
        [self.viewerWindow makeKeyAndOrderFront:self];
        
        [self setLoadingFinishTime:[NSDate timeIntervalSinceReferenceDate]];
    }
}

- (void)_loadImage
{
    NSString * urlString = self.media.middleImage;
    
    if (!urlString)
    {
        return;
    }
    
    NSURL * url = [NSURL URLWithString:urlString];
    WTImageRequest * request = [WTImageRequest requestWithURL:url];
    request.delegate = self;
    request.downloadProgressDelegate = self;
    request.statusCheckingInterval = 0.05;

    [request startAsynchronous];
    [self setCurrentRequest:request];
    
    _flags.loadingStarted = YES;
}

- (void)_dissociateSourceView
{
    [self.loaderView removeFromSuperview];
    [self setSourceView:nil];
    [self setSourcePoint:CGPointZero];
}

- (BOOL)_updateLoaderVisibility
{
    if (self.sourceView)
    {
        if (![[self.sourceView mediaObject] isEqual:self.media] ||
            ![self.sourceView superview] ||
            _flags.loadingFinished)
        {
            [self _dissociateSourceView];
            
            return NO;
        }
        
        if (self.loaderView.superview != self.sourceView)
        {
            [self.sourceView addSubview:self.loaderView];
            [self.loaderView setCenter:self.sourcePoint];
        }
        
        return YES;
    }
    else
    {
        [self.loaderView removeFromSuperview];
        
        return NO;
    }
}

- (void)_updateLoaderWithProgress:(CGFloat)progress
{
    if ([self _updateLoaderVisibility])
    {
        [self.loaderView setProgress:progress];
    }
}

#pragma mark - ASIHttpRequestDelegate & ASIProgressDelegate

- (void)setMaxValue:(double)newMax
{
    [self _updateLoaderWithProgress:0];
}

- (void)setDoubleValue:(double)newProgress
{
    [self _updateLoaderWithProgress:newProgress];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self _dissociateSourceView];
    [self close];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self _updateLoaderWithProgress:1.0];
    
    NSData * imageData = request.responseData;
    TUIImage * image = [TUIImage imageWithData:imageData];
        
    [self.viewerWindow setPicture:self.media];
    [self.viewerWindow setImage:image animated:NO sizeWindowToFit:YES];
    
    [self setLoadingFinishTime:[NSDate timeIntervalSinceReferenceDate]];
    
//    CGRect sourceRect = CGRectZero;
//    if (self.sourceView)
//    {
//        sourceRect = [self.sourceView frameOnScreen];
//    }
    
    _flags.loadingFinished = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateLoaderVisibility];
    });
    
    [self.viewerWindow makeKeyAndOrderFront:self];
    
//    if (CGRectIsEmpty(sourceRect))
//    {
//        [self.viewerWindow makeKeyAndOrderFront:self];
//    }
//    else
//    {
//        self.viewerWindow.animationBehavior = NSWindowAnimationBehaviorNone;
//        
//        CAMediaTimingFunction * timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        
//        CGFloat scale = sourceRect.size.width / self.viewerWindow.frame.size.width;
//
//        CGPoint startCenter = CGRectGetCenter(sourceRect);
//        CGPoint endCenter = CGRectGetCenter(self.viewerWindow.frame);
//        
//        CGPoint offset = CGPointMake(startCenter.x - endCenter.x, startCenter.y - endCenter.y);
//        
//        [self.viewerWindow makeKeyAndOrderFrontWithDuration:0.3 timing:timingFunction setup:^(CALayer *windowLayer) {
//            windowLayer.anchorPoint = CGPointMake(0.5, 0.5);
//            CATransform3D scaleTransform = CATransform3DMakeScale(scale, scale, 1);
//            CATransform3D offsetTransform = CATransform3DMakeTranslation(offset.x, offset.y, 0);
//            windowLayer.transform = CATransform3DConcat(scaleTransform, offsetTransform);
//        } animations:^(CALayer *layer) {
//            layer.transform = CATransform3DIdentity;
//        }];
//    }
}

@end

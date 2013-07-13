//
//  WUIAsyncViewRenderer.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WUIAsyncViewRendererDelegate;

@interface WUIAsyncViewRenderer : NSObject

@property (nonatomic, assign) id<WUIAsyncViewRendererDelegate> delegateView;

- (void)renderInContext:(CGContextRef)context asynchronously:(BOOL)async;

@end

@protocol WUIAsyncViewRendererDelegate <NSObject>

@end
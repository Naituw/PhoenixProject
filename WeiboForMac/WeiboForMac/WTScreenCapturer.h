//
//  WTScreenCapturer.h
//  WTScreenCapture
//
//  Created by Wutian on 12-1-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WTScreenCapturerDelegate;




@interface WTScreenCapturer : NSObject{
    NSUInteger pboardChangeCount;
    id<WTScreenCapturerDelegate> _delegate;
}
@property (assign) id<WTScreenCapturerDelegate> delegate;
- (void)startCapture;
@end




@protocol WTScreenCapturerDelegate <NSObject>

@required
- (void)screenCapturer:(WTScreenCapturer *)capturer didFinishWithImageData:(NSData *)data;

@end

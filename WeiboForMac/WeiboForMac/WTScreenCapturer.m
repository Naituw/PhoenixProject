//
//  WTScreenCapturer.m
//  WTScreenCapture
//
//  Created by Wutian on 12-1-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTScreenCapturer.h"

#define SCREEN_CAPTURE_PATH @"/usr/sbin/screencapture"

@interface WTScreenCapturer()
-(void)checkCaptureTaskStatus:(NSNotification *)aNotification;
@end

@implementation WTScreenCapturer
@synthesize delegate = _delegate;

- (id)init{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)startCapture{
    pboardChangeCount = [[NSPasteboard generalPasteboard] changeCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkCaptureTaskStatus:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    
    NSTask *aTask = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObject:@"-ci"];
    [aTask setLaunchPath:SCREEN_CAPTURE_PATH];
    [aTask setArguments:args];
    [aTask launch];
    [aTask autorelease];
}

- (void)captureFinished{
    NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
    NSArray *imageTypesAry = [NSArray arrayWithObjects:NSPasteboardTypePNG, nil];
    NSString *desiredType = [pasteboard availableTypeFromArray:imageTypesAry];
    if ([desiredType isEqualToString:NSPasteboardTypePNG]) {
        NSData *imageData   = [pasteboard dataForType:desiredType];
		if (imageData == nil) {
			NSLog(@"capture failed! data is nil.");
			return;
		}
        if ([_delegate respondsToSelector:@selector(screenCapturer:didFinishWithImageData:)]) {
            [_delegate screenCapturer:self didFinishWithImageData:imageData];
        }
    }
}

- (void)checkCaptureTaskStatus:(NSNotification *)aNotification{
    NSTask * aTask = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
    if (![aTask isRunning] && [[aTask launchPath] isEqualToString:SCREEN_CAPTURE_PATH]) {
        int status = [aTask terminationStatus];
        if (status == 0)
            if (pboardChangeCount == [[NSPasteboard generalPasteboard] changeCount]) {
                NSLog(@"capture task canceled.");
            }else{
                [self captureFinished];
            }
        else
            NSLog(@"capture task failed.");
    }
}

@end

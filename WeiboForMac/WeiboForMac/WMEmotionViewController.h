//
//  WMEmotionViewController.h
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebUIDelegate.h>

@protocol WMEmotionDelegate;

@interface WMEmotionViewController : NSViewController

@property (nonatomic, assign) id<WMEmotionDelegate> delegate;
@property (nonatomic, retain) WebView * emojiView;

- (void)destory;

@end

@protocol WMEmotionDelegate <NSObject>
@optional
- (void)emotionViewController:(WMEmotionViewController *)controller didSelectEmotion:(NSString *)phrase;
@end

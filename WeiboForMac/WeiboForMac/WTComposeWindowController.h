//
//  WTComposeWindowController.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WTComposeTextView.h"
#import "WTScreenCapturer.h"
#import "WeiboStatus.h"
#import "EGOImageLoader.h"
#import "WTAutoCompleteWindow.h"
#import "WMEmotionViewController.h"
#import "WTComposeWindow.h"

@class WMComposition, WeiboAccount;

typedef enum {		
	WTComposeTypeNew = 0,
	WTComposeTypeReply,
	WTComposeTypeRepost
} WTComposeType;

@interface WTComposeWindowController : NSWindowController 
<WTComposeTextViewDelegate, WTScreenCapturerDelegate, NSWindowDelegate,EGOImageLoaderObserver, WTAutoCompleteDelegate, NSAnimationDelegate, WMEmotionDelegate, NSPopoverDelegate, NSTextViewDelegate>
{
    WeiboAccount * account;
    WTScreenCapturer * capturer;
    WTAutoCompleteWindow * autocompleteWindow;
    NSArray * autocompleteItems;
    
    NSString * initialText;
    NSRange initialRange;
}

@property(retain, nonatomic) NSPopover * popover;
@property(retain, nonatomic) WeiboAccount *account;
@property(retain, nonatomic) NSString * initialText;

#pragma mark -
#pragma mark Accessor

+ (CGSize)defaultWindowSize;

- (WTComposeWindow *)composeWindow;
- (WMComposition *)composition;
- (WeiboAccount *)selectedAccount;
- (NSData *)imageData;
- (void)setImageData:(NSData *)imageData;
- (NSString *)textToPost;
- (void)setInitialText:(NSString *)string selectedRange:(NSRange)range;
- (BOOL)canSendImage;

#pragma mark -
#pragma mark UserInterface
- (void)accountChanged;

#pragma mark -
#pragma mark Actions
- (void)captureImage;
- (void)selectLocalImage;
- (void)setImageDataToUpload:(NSData *)imageData;
- (IBAction)post:(id)sender;
- (void)toggleEmotionPopover:(id)sender;
- (void)performClose:(id)sender;

#pragma mark -
#pragma mark Autocomplete

- (void)prepareAutoCompleteMenu;
- (void)updateAutoCompleteItems;
- (void)cancelAutocomplete;
- (void)autocompletingText:(NSString *)text inRect:(NSRect)rect;

@end

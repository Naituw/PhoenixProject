//
//  WTComposeWindow.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TUINSWindow.h"

#define BOTTOMBAR_HEIGHT 46.0
#define METASTRING_AREA_HEIGHT 0.0//25.0

@class WTComposeTextView;
@class WTComposeAvatarView;
@class WTComposerButton;
@class WTImageAttachmentButton;
@class WTComposeWindowController;
@class WMEmojiCollectorView;

enum {
    WTComposeWindowNippleDirectionLeft,
    WTComposeWindowNippleDirectionRight,
};
typedef NSInteger WTComposeWindowNippleDirection;

@interface WTComposeWindow : TUINSWindow <NSTextViewDelegate> {
    WTComposeTextView *     textView;
    WTComposeAvatarView *   avatarView;
    NSTextField *           countLabel;
    
    WTComposerButton * postButton;
    WTComposerButton * cancelButton;
    WTComposerButton * addButton;
    WTComposerButton * emojiButton;
    
    WTImageAttachmentButton * imageButton;
    
    WTComposeWindowController * _controller;
    
    WMEmojiCollectorView * containerView;
}

@property (nonatomic, assign) WTComposeWindowController * controller;
@property (nonatomic, readonly) WTComposerButton * emojiButton;

@property (nonatomic, assign) BOOL shouldShowNipple;
@property (nonatomic, assign) WTComposeWindowNippleDirection nippleDirection;

- (void)windowDidFinishDisplaying;
- (NSString *)textToPost;
- (NSImage *)attachmentImage;
- (void)setAttachmentButtonImage:(NSImage *)image;
- (CGFloat)minHeightOfWindow;
- (void)setAvatarImage:(NSImage *)anImage;
- (void)setText:(NSString *)text selectedRange:(NSRange)range;
- (void)setComposeButtonTitle:(NSString *)title;
- (WTComposeTextView *)textView;

+ (NSArray *)composeWindows;
+ (void)dissociateAllNipples;
- (void)dissociateNipple;

@property (nonatomic, assign) NSInteger selectedAccountIndex;

@end

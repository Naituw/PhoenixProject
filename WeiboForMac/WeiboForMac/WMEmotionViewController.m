//
//  WMEmotionViewController.m
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMEmotionViewController.h"
#import "WeiboEmotionManager.h"

@implementation WMEmotionViewController
@synthesize emojiView = _emojiView, delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (void)destory
{
    [self.emojiView removeFromSuperview];
    self.emojiView = nil;
}


- (void)loadView
{
    CGFloat padding = 10;
    NSRect rect = NSMakeRect(0, 0, 405 + 2 * padding, 187 + 2 * padding);
    NSView * container = [[NSView alloc] initWithFrame:rect];
    self.emojiView = [[[WebView alloc] initWithFrame:NSInsetRect(rect, padding, padding)] autorelease];
    self.emojiView.UIDelegate = self;
    self.emojiView.frameLoadDelegate = self;
    self.emojiView.editingDelegate = self;
    self.emojiView.drawsBackground = NO;
    [self.emojiView.windowScriptObject setValue:self forKey:@"AppController"];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[WeiboEmotionManager sharedManager].url];
    [[self.emojiView mainFrame] loadRequest:request];

    
    [container addSubview:self.emojiView];

    self.view = [container autorelease];
}

- (void)emotionClicked:(NSString *)phrase
{
    if ([self.delegate respondsToSelector:@selector(emotionViewController:didSelectEmotion:)]) {
        [self.delegate emotionViewController:self didSelectEmotion:phrase];
    }
}



#pragma mark - WebView Delegate.
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(emotionClicked:)) {
        return NO;
    }
    return YES;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil; // disable contextual menu for the webView
}

- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange 
     toDOMRange:(DOMRange *)proposedRange 
       affinity:(NSSelectionAffinity)selectionAffinity 
 stillSelecting:(BOOL)flag
{
    // disable text selection
    return NO;
}

- (NSUInteger)webView:(WebView *)sender dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo{
    return WebDragDestinationActionNone;
}
- (NSUInteger)webView:(WebView *)sender dragSourceActionMaskForPoint:(NSPoint)point{
    return WebDragSourceActionNone;
}

@end

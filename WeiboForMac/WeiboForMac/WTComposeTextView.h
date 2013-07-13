//
//  WTComposeTextView.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-23.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WTComposeTextViewDelegate;

@interface WTComposeTextView : NSTextView {
    BOOL isAutoCompleting;
    id<WTComposeTextViewDelegate> _composeDelegate;
}

@property (readwrite, assign) id<WTComposeTextViewDelegate> composeDelegate;
@property (assign, nonatomic) BOOL isAutoCompleting;

@end

@protocol WTComposeTextViewDelegate <NSObject>

@required
- (void)textView:(WTComposeTextView *)textView didReceiveDragedImageData:(NSData *)imageData;
- (void)textViewDidConfirmAutoComplete:(WTComposeTextView *)textView;
- (void)textViewDidHighlightNextAutoComplete:(WTComposeTextView *)textView;
- (void)textViewDidHighlightPreviousAutoComplete:(WTComposeTextView *)textView;
- (void)textViewDidCancelAutoComplete:(WTComposeTextView *)textView;
@end
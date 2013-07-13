//
//  WTWebImageView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIImageView.h"
#import "EGOImageLoader.h"

@interface WTWebImageView : WUIView <EGOImageLoaderObserver> {
    NSURL* imageURL;
}

@property(nonatomic,retain) TUIImage * image;
@property(nonatomic,retain) NSURL* imageURL;
@property(nonatomic,assign) BOOL loading;
@property(nonatomic,assign) BOOL loaded;

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(TUIImage *)placeholder;
- (void)setImageFromCacheWithURL:(NSURL *)url  style:(NSString *)style;
- (void)setImageWithURL:(NSURL *)url style:(NSString *)style styler:(NSData* (^)(NSData* imageData))styler;
- (void)cancelCurrentImageLoad;

- (TUIImage *)defalutPlaceholder;

@end

enum {
    WMWebImageDrawingStyleNone,
    WMWebImageDrawingStyleMacAvatar,
    WMWebImageDrawingStyleMacThumb,
};
typedef NSInteger WMWebImageDrawingStyle;

@interface WTWebImageView (WMAdditions)

- (void)setImageWithURL:(NSURL *)url drawingStyle:(WMWebImageDrawingStyle)drawingStyle;

@end

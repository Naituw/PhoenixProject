//
//  WTImageViewer.h
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-1.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIKit.h"
#import "WTProgressBar.h"
#import "WTImageRequest.h"
#import "WeiboPicture.h"
#import "WTHUDStatusView.h"

@class WTImageView;

@interface WTImageViewer : TUINSWindow

@property (nonatomic, retain) WTImageRequest * currentRequest;
@property (nonatomic, retain) WeiboPicture * picture;

+ (void)viewImageWithImageURL:(NSString *)imageURL;

- (void)viewImageAtUrl:(NSString *)urlString;

- (void)savePhoto:(id)sender;
- (void)downloadBigPhoto:(id)sender;

- (void)setImage:(TUIImage *)image;
- (void)setImage:(TUIImage *)image animated:(BOOL)animated sizeWindowToFit:(BOOL)sizeWindow;

- (void)sizeWindowToFit:(CGSize)size;

@end

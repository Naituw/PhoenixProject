//
//  TUIImage+UIPrivate.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIImage.h"

@class NSImage;

@interface TUIImage (UIPrivate)
+ (NSString *)_macPathForFile:(NSString *)path;		// inserts "@mac" into the filename of the file in the given path and returns the result
+ (NSString *)_pathForFile:(NSString *)path;		// uses above, checks for existence, if found, returns it otherwise returns the path string un-altered (doesn't verify that the file at the original path exists, though)

+ (void)_cacheImage:(TUIImage *)image forName:(NSString *)name;
+ (NSString *)_nameForCachedImage:(TUIImage *)image;
+ (TUIImage *)_cachedImageForName:(NSString *)name;
+ (TUIImage *)_backButtonImage;
+ (TUIImage *)_highlightedBackButtonImage;
+ (TUIImage *)_toolbarButtonImage;
+ (TUIImage *)_highlightedToolbarButtonImage;
+ (TUIImage *)_leftPopoverArrowImage;
+ (TUIImage *)_rightPopoverArrowImage;
+ (TUIImage *)_topPopoverArrowImage;
+ (TUIImage *)_bottomPopoverArrowImage;
+ (TUIImage *)_popoverBackgroundImage;
+ (TUIImage *)_roundedRectButtonImage;
+ (TUIImage *)_highlightedRoundedRectButtonImage;
+ (TUIImage *)_windowResizeGrabberImage;
+ (TUIImage *)_buttonBarSystemItemAdd;
+ (TUIImage *)_buttonBarSystemItemReply;
+ (TUIImage *)_tabBarBackgroundImage;
+ (TUIImage *)_tabBarItemImage;

- (TUIImage *)_toolbarImage;		// returns a new image which is modified as required for toolbar buttons (turned into a solid color)
+ (TUIImage *)_imageFromNSImage:(NSImage *)ns;
@end

// this is used by stretchable images to break the NSImage into multiple parts
NSImage *_NSImageCreateSubimage(NSImage *theImage, CGRect rect);

//
//  WTEventHandler.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-28.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WeiboConstants.h"

@class WeiboBaseStatus, TUIImage;

@interface WTEventHandler : NSObject

+ (void)openURL:(NSString *)urlString;
+ (void)openURL:(NSString *)urlString inBackground:(BOOL)background;

// fast access.
+ (void)openHomePage;
+ (void)openSearchPage;
+ (void)openMessagePage;
+ (void)openFollowserPageForUserID:(WeiboUserID)uid;
+ (void)openFollowingPageForUserID:(WeiboUserID)uid;
+ (void)openUserPageForUserID:(WeiboUserID)uid;
+ (void)openStatusPageForStatus:(WeiboBaseStatus *)status;

+ (void)openHashTag:(NSString *)tag;

@end

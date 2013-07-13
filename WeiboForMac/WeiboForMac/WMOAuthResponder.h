//
//  WMOAuthResponder.h
//  WeiboForMac
//
//  Created by Wutian on 13-6-24.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WMOAuthResponder <NSObject>

- (BOOL)shouldAddAccountWithAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID;

- (void)willVerifyAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID;
- (void)finishedVerifingAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID error:(NSError *)error;

- (NSWindow *)windowForOAuthModalAlert;

@end

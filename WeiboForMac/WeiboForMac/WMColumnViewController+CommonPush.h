//
//  WMColumnViewController+CommonPush.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-15.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMColumnViewController.h"
#import "WeiboAccount.h"

@interface WMColumnViewController (CommonPush)

- (BOOL)pushUserViewControllerWithUsername:(NSString *)username account:(WeiboAccount *)account;
- (BOOL)pushUserViewControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account;
- (BOOL)pushTrendViewControllerWithTrendName:(NSString *)name account:(WeiboAccount *)account;

- (BOOL)pushUserFollowerListControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account;
- (BOOL)pushUserFollowingListControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account;

@end

//
//  WMComposition.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

#import "WeiboComposition.h"
#import "WeiboAccount.h"

@interface WMComposition : NSDocument <WeiboComposition, CLLocationManagerDelegate>

@property (nonatomic, assign, readonly) BOOL isSending;
@property (nonatomic, assign) int urlLength;
@property (nonatomic, assign) BOOL hadFailedSend;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, assign) BOOL isDraft;

@property (nonatomic, retain) WTCallback * didSendCallback;

- (void)_sendFromAccount:(WeiboAccount *)account;
- (void)sendFromAccount:(WeiboAccount *)account;
- (void)refreshLocation;

@end

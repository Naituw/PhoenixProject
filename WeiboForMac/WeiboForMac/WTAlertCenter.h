//
//  WTAlertCenter.h
//  WeiboForMac
//
//  Created by Wutian on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTAlertView.h"

@interface WTAlertCenter : NSObject {
    NSMutableArray * _displayingAlerts;
}

+ (WTAlertCenter *)sharedCenter;

- (void) hideAlertView:(WTAlertView *)alertView;
- (void) hideAllAlert;
- (void) postErrorWithTitle:(NSString *)title;
- (void) postTipWithTitle:(NSString *)title;
- (void) postAlertWithTitle:(NSString *)title style:(WTAlertStyle)style;

@end

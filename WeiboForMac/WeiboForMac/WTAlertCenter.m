//
//  WTAlertCenter.m
//  WeiboForMac
//
//  Created by Wutian on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WTAlertCenter.h"
#import "WTAlertView.h"
#import <Quartz/Quartz.h>

@implementation WTAlertCenter
static WTAlertCenter * shared = nil;

+ (WTAlertCenter *)sharedCenter{
    if (!shared) {
        shared = [[[self class] alloc] init];
    }
    return shared;
}

- (id)init{
    if((self = [super init])){
        _displayingAlerts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) hideAlertView:(WTAlertView *)alertView{
    [TUIView animateWithDuration:0.4
                           delay:0.0 
                           curve: TUIViewAnimationCurveEaseInOut
                      animations:^(void) {
                          alertView.frame = CGRectOffset(alertView.frame, 0, -(BAR_HEIGHT + BAR_SHADOW));
                      }
                      completion:^(BOOL finished) {
                          [alertView removeFromSuperview];
                          [_displayingAlerts removeObject:alertView];
                      }];
}
- (void) showAlertView:(WTAlertView *)alertView{
    [TUIView animateWithDuration:0.4
                           delay:0.0 
                           curve: TUIViewAnimationCurveEaseInOut
                      animations:^(void) {
                          alertView.frame = CGRectOffset(alertView.frame, 0, BAR_HEIGHT + BAR_SHADOW);
                      }
                      completion:^(BOOL finished) {
                      }];
}
- (void) hideAllAlert{
    for(WTAlertView * alertView in _displayingAlerts){
        [self hideAlertView:alertView];
    }
}

- (void) postErrorWithTitle:(NSString *)title{
    [self postAlertWithTitle:title style:WTAlertStyleError];
}
- (void) postTipWithTitle:(NSString *)title{
    [self postAlertWithTitle:title style:WTAlertStyleTip];
}
- (void) postAlertWithTitle:(NSString *)title style:(WTAlertStyle)style{
    /*
    WTColumnViewController * navController = [[NSApp delegate] rootViewController].columnViewController;
    CGRect b = navController.view.bounds;
    CGFloat barHeight = 26;
    CGFloat barShadow = 6;
    CGRect init = CGRectMake(0, -(barHeight + barShadow), b.size.width, barHeight);
    WTAlertView * alertView = [[WTAlertView alloc] initWithTitle:title style:WTAlertStyleTip];
    alertView.frame = init;
    [CATransaction begin];
    [navController.view addSubview:alertView];
    [CATransaction flush];
    [CATransaction commit];
    
    [_displayingAlerts addObject:alertView];
    [alertView release];
    
    [self performSelector:@selector(showAlertView:) withObject:alertView afterDelay:0.0];
    [self performSelector:@selector(hideAlertView:) withObject:alertView afterDelay:5.0];
     */
}


@end

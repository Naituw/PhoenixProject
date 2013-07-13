//
//  WTEventHandler.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-28.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTEventHandler.h"
#import "WTImageViewer.h"
#import "WeiboBaseStatus.h"
#import "WeiboUser.h"

@implementation WTEventHandler

+ (BOOL)openLinkInBackground
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"open-links-in-background"];
}

+ (void)openURL:(NSString *)urlString{
    [self openURL:urlString inBackground:[self openLinkInBackground]];
}
     
+ (void)openURL:(NSString *)urlString inBackground:(BOOL)background{
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray* urls = [NSArray arrayWithObject:[NSURL URLWithString:urlString]];
    NSWorkspaceLaunchOptions option = NSWorkspaceLaunchDefault;
    if (background)
    {
        option = NSWorkspaceLaunchWithoutActivation;
    }
    [[NSWorkspace sharedWorkspace]
                   openURLs:urls
                   withAppBundleIdentifier:nil
                   options:option
                   additionalEventParamDescriptor:nil
                   launchIdentifiers:nil];
}

+ (void)openHomePage
{
    [self openURL:@"http://weibo.com/"];
}
+ (void)openSearchPage
{
    [self openURL:@"http://s.weibo.com/"];
}
+ (void)openMessagePage
{
    [self openURL:@"http://weibo.com/messages"];
}
+ (void)openFollowserPageForUserID:(WeiboUserID)uid
{
    NSString * urlString = [NSString stringWithFormat:@"http://weibo.com/%lld/fans",uid];
    [self openURL:urlString];
}
+ (void)openFollowingPageForUserID:(WeiboUserID)uid
{
    NSString * urlString = [NSString stringWithFormat:@"http://weibo.com/%lld/follow",uid];
    [self openURL:urlString];
}
+ (void)openUserPageForUserID:(WeiboUserID)uid
{
    NSString * urlString = [NSString stringWithFormat:@"http://weibo.com/%lld",uid];
    [self openURL:urlString];
}

+ (NSString *)base62FromDouble:(double)value
{
	NSString *base62 = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger baseLength = [base62 length];
    NSMutableString *returnValue = [NSMutableString string];
	double g = value;
	while (g != 0) {
		int x = fmod(g,baseLength);
		NSString *y = [base62 substringWithRange:NSMakeRange(x, 1)]; 
		[returnValue insertString:y atIndex:0];
		value /= baseLength;
		g = round(value - 0.5);
	}
	return returnValue;
}
+ (NSString *)midFromId:(WeiboStatusID)sid{
    NSMutableString * url = [NSMutableString string];
	NSString * idString = [NSString stringWithFormat:@"%lld",sid];
	for (int i = (int)(idString.length - 7); i > -7; i = i - 7){
		NSString * temp = [idString substringWithRange:NSMakeRange(i < 0? 0:i, i < 0? i + 7:7)];	
		temp = [self base62FromDouble:[temp doubleValue]];
        NSInteger zerosToFill = 4 - temp.length;
        if (i > 0) {
            for (int j = 0; j < zerosToFill; j++) {
                [url insertString:@"0" atIndex:0];
            }
        }else {
            zerosToFill = 0;
        }
		[url insertString:temp atIndex:zerosToFill];
	}
    return url;
}

+ (void)openStatusPageForStatus:(WeiboBaseStatus *)status
{
    NSString * url = [NSString stringWithFormat:@"http://weibo.com/%lld/%@",status.user.userID,[self midFromId:status.sid]];
    [self openURL:url];
}

+ (void)openHashTag:(NSString *)tag
{
    NSString * fullUrl = [@"http://s.weibo.com/weibo/" stringByAppendingString:tag];
    [self openURL:fullUrl];
}

@end

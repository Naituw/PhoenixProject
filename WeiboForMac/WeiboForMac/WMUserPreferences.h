//
//  WMUserPreferences.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WMUserDisplayPreferenceSetDidChangeNotification;

@interface WMUserPreferences : NSObject

+ (WMUserPreferences *)sharedPreferences;

@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) BOOL showsThumbImage;
@property (nonatomic, assign) BOOL placeThumbImageOnSideOfCell;

@end

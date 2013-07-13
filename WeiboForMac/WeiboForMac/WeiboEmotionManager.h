//
//  WeiboEmotionManager.h
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboEmotionManager : NSObject

@property (nonatomic, copy) NSString * derivedHTML;
@property (nonatomic, retain) NSArray * emotions;
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, readonly) NSURL * url;

+ (WeiboEmotionManager *)sharedManager;

@end

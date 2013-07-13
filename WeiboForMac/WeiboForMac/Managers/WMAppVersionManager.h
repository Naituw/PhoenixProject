//
//  WMAppVersionManager.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-7-9.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMAppVersionManager : NSObject

@property (readonly) NSUInteger configuredBuild;

+ (WMAppVersionManager *)defaultManager;

- (void)configure;

@end

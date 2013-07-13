//
//  WMAppVersionManager.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-7-9.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <objc/runtime.h>
#import "WMAppVersionManager.h"
#import "LocalAutocompleteDB.h"

#define kDefaultsConfiguredBuild @"configured-build"

@interface WMAppVersionManager ()

@end

@implementation WMAppVersionManager

+ (WMAppVersionManager *)defaultManager{
    static WMAppVersionManager * _defaultManager = nil;
    @synchronized(self){
        if (!_defaultManager) 
            _defaultManager = [[WMAppVersionManager alloc] init];
        return _defaultManager;
    }
}

- (NSUInteger)configuredBuild{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSUInteger build = [[ud objectForKey:kDefaultsConfiguredBuild] longLongValue];
    return build;
}
- (void)configure{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* buildString = [infoDict objectForKey:@"CFBundleVersion"];
    NSUInteger currentBuild = [buildString longLongValue];
    NSUInteger configuredBuild = [self configuredBuild];
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(object_getClass(self), &mc);
    for(int i = 0;i < mc;i++){
        NSString * name = [NSString stringWithCString:sel_getName(method_getName(mlist[i])) 
                                             encoding:NSUTF8StringEncoding];
        if ([name hasPrefix:@"configureBuild"]) {
            NSUInteger build = [[name substringFromIndex:14] longLongValue];
            if (build > configuredBuild) {
                [self performSelector:NSSelectorFromString(name)];
            }
        }
    }
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSString stringWithFormat:@"%ld",currentBuild] forKey:kDefaultsConfiguredBuild];
}

- (void)configureBuild3730{
    [LocalAutocompleteDB resetDatabase];
}

@end

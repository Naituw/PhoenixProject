//
//  WMUserPreferences.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserPreferences.h"

NSString * const WMUserDisplayPreferenceSetDidChangeNotification = @"WMUserDisplayPreferenceSetDidChangeNotification";

@interface WMUserPreferences ()

@end

@implementation WMUserPreferences

- (void)dealloc
{
    [super dealloc];
}

static NSArray * displayPreferencesKeys;
static NSDictionary * userDefaultsKeyMap;
static NSDictionary * defaultValueMap;
static WMUserPreferences * _preferences;

+ (WMUserPreferences *)sharedPreferences
{
    return _preferences;
}

+ (id)_alloc
{
    return [super allocWithZone:nil];
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPreferences] retain];
}
+ (id)alloc
{
    return [[self sharedPreferences] retain];
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayPreferencesKeys = [@[@"fontSize",@"showsThumbImage",@"placeThumbImageOnSideOfCell"] retain];
        
        userDefaultsKeyMap = [@{@"fontSize":@"fontSize",
                               @"showsThumbImage":@"showsThumbImage",
                              @"placeThumbImageOnSideOfCell":@"placeThumbImageOnSideOfCell"} retain];
        
        defaultValueMap = [@{@"fontSize":@(13),
                            @"showsThumbImage":@(YES),
                           @"placeThumbImageOnSideOfCell":@(YES)} retain];
        
        _preferences = [[WMUserPreferences _alloc] _init];
    });
}

- (void)restoreFromUserDefaults
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    for (NSString * key in userDefaultsKeyMap.allKeys)
    {
        NSString * userDefaultsKey = userDefaultsKeyMap[key];
        id value = [ud objectForKey:userDefaultsKey];
        
        if (!value)
        {
            id defaultValue = defaultValueMap[key];
            if (defaultValue)
            {
                [ud setValue:defaultValue forKeyPath:userDefaultsKey];
                value = defaultValue;
            }
        }
        
        [super setValue:value forKeyPath:key];
    }
}

- (id)_init
{
    if (self = [super init])
    {
        [self restoreFromUserDefaults];
    }
    return self;
}

- (id)init
{
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return self;
}


- (BOOL)isDisplayPreferenceForKeyPath:(NSString *)keyPath
{
    return [displayPreferencesKeys containsObject:keyPath];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    [super setValue:value forKeyPath:keyPath];
    
    NSString * userDefaultsKey = userDefaultsKeyMap[keyPath];
    
    if (userDefaultsKey)
    {
        [[NSUserDefaults standardUserDefaults] setValue:value forKeyPath:userDefaultsKey];
    }
    
    if ([self isDisplayPreferenceForKeyPath:keyPath])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WMUserDisplayPreferenceSetDidChangeNotification object:self];
    }
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    return [super valueForKeyPath:keyPath];
}

@end

//
//  WTWeakMap.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTWeakMap.h"

@implementation WTWeakMap

- (id)init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc{
    [dictionary release];
    [super dealloc];
}

- (id)objectForKey:(id)key{
    return [dictionary objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key{
    [dictionary setObject:object forKey:key];
    [object release];
}

- (void)removeObjectForKey:(id)key{
    //[[dictionary objectForKey:key] retain];
    //[dictionary removeObjectForKey:key];
}

- (int)count{
    return (int)[dictionary count];
}

@end

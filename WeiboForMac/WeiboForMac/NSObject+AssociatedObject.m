//
//  NSObject+AssociatedObject.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-11.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "NSObject+AssociatedObject.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedObject)

- (id)objectWithAssociatedKey:(NSString *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)setObject:(id)object forAssociatedKey:(NSString *)key retained:(BOOL)retain
{
    objc_setAssociatedObject(self, key, object, retain?OBJC_ASSOCIATION_RETAIN_NONATOMIC:OBJC_ASSOCIATION_ASSIGN);
}

@end

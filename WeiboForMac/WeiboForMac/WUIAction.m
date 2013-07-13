//
//  WUIAction.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIAction.h"

@implementation WUIAction

- (BOOL)isEqual:(id)object
{
    
    if (object == self) {
        return YES;
    } else if ([object isKindOfClass:[self class]]) {
        return ([object target] == self.target && [object action] == self.action);
    } else {
        return NO;
    }
}

@end

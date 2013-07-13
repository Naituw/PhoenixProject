//
//  NSObject+AssociatedObject.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-11.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociatedObject)

- (id)objectWithAssociatedKey:(NSString *)key;
- (void)setObject:(id)object forAssociatedKey:(NSString *)key retained:(BOOL)retain;

@end

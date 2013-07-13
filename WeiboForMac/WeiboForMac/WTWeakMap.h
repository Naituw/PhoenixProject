//
//  WTWeakMap.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

@interface WTWeakMap : NSObject {
    NSMutableDictionary *dictionary;
}

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (int)count;

@end

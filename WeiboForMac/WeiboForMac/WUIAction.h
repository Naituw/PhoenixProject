//
//  WUIAction.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUIAction : NSObject

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@end

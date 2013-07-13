//
//  WTDateFormatter.h
//  weibo3
//
//  Created by 吴天 on 11-7-15.
//  Copyright 2011年 nfsysu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WTDateFormatter : NSObject {
@private
}

+ (WTDateFormatter * ) shared;
- (NSString *) stringForTime:(int)time;

@end

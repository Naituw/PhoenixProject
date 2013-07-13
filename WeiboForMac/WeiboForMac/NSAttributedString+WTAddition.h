//
//  TUIAttributedString+WTAddition.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"

@interface NSAttributedString (WTAddition)

- (NSCharacterSet *) httpDelimitingCharset;
- (NSCharacterSet *) usernameDelimitingCharset;
- (NSCharacterSet *) hashtagDelimitingCharset;
- (NSString *) detectURL:(NSString *)string;
- (NSString *) detectUsername:(NSString *)string;
- (NSString *) detectHashtag:(NSString *)string;

//- (NSAttributedString *) emoticonStringWithName:(NSString *)name;
- (NSArray *) activeRanges;


@end

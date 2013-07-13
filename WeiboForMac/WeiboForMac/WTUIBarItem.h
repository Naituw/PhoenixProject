//
//  WTUIBarItem.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIGeometry.h"

@class TUIImage;

@interface WTUIBarItem : NSObject {
@private
    BOOL _enabled;
    TUIImage *_image;
    TUIEdgeInsets _imageInsets;
    NSString *_title;
    NSInteger _tag;
}

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, retain) TUIImage *image;
@property (nonatomic, assign) TUIEdgeInsets imageInsets;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSInteger tag;

@end

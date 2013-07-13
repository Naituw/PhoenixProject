//
//  WTUIToolBar.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIInterface.h"

@interface WTUIToolbar : WUIView {
@private
    UIBarStyle _barStyle;
    TUIColor *_tintColor;
    NSMutableArray *_toolbarItems;
    BOOL _translucent;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@property (nonatomic) UIBarStyle barStyle;
@property (nonatomic, retain) TUIColor *tintColor;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic,assign,getter=isTranslucent) BOOL translucent;

@end

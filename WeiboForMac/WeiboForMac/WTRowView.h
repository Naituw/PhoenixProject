//
//  WTRowView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@protocol WTRowViewDelegate;

@interface WTRowView : WUIView {
    id <WTRowViewDelegate> delegate;
    id target;
    SEL action;
    id userInfo;
    BOOL dynamicHeight;
    WTRowView * parentRow;
    NSMutableArray * childRows;
    CGFloat rowHeight;
    struct {
        unsigned int selectable:1;
        unsigned int highlighted:1;
        unsigned int selected:1;
        unsigned int deferUpdate:5;
        unsigned int cleanRowHeight:1;
        unsigned int plainSetFrame:1;
        unsigned int fadeNextContentsChange:1;
        unsigned int forceGroupedStyle:1;
    } _flags;
    NSMenu * menu;
}

@property(readonly, nonatomic) BOOL isFirst;
@property(readonly, nonatomic) BOOL isLast;
@property(readonly, nonatomic) BOOL isGrouped;
@property(readonly, nonatomic) WTRowView *rootRow;
@property(copy, nonatomic) NSArray *childRows;
@property(assign, nonatomic) CGFloat rowHeight;
@property(assign, nonatomic) BOOL selectable;
@property(assign, nonatomic) BOOL highlighted;
@property(assign, nonatomic) BOOL selected;
@property(retain, nonatomic) NSMenu *menu;
@property(assign, nonatomic) BOOL dynamicHeight;
@property(assign, nonatomic) WTRowView *parentRow;
@property(retain, nonatomic) id userInfo;
@property(assign, nonatomic) id <WTRowViewDelegate> delegate;


+ (WTRowView *)row;
+ (WTRowView *)sectionHeader:(NSString *)text;
+ (WTRowView *)spacerRow:(CGFloat)rowHeight;
+ (id)divider:(id)arg1;
+ (WTRowView *)loadingRow;
- (NSMenu *)menuForEvent:(NSEvent *)event;
- (id)initWithFrame:(CGRect)frame;
- (id)init;
- (void)dealloc;
- (void)beginChanges;
- (void)endChanges;
- (void)_childRowsChanged;
- (NSString *)description;
- (void)_setupFrame:(WTRowView *)rowView;
- (TUIView *)childContainer;
- (void)_add:(WTRowView *)newRow;
- (void)_remove:(WTRowView *)oldRow;
- (void)_mightHaveRemovedAllChildren;
- (WTRowView *)addChildRow:(WTRowView *)newRow;
- (void)removeChildRow:(WTRowView *)oldRow;
- (void)replaceChildRow:(WTRowView *)oldRow withRow:(WTRowView *)newRow;
- (CGFloat)calculatedRowHeight;
- (CGFloat)childWidth:(CGFloat)selfWidth;
- (CGFloat)xOffset;
- (CGFloat)_updateLayout:(CGFloat)arg1 width:(CGFloat)width xOffset:(CGFloat)xOffset;
- (void)layoutSubviews;
- (void)updateLayout;
- (void)setFrame:(CGRect)frame;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setNeedsDisplay;
- (void)_deselectRowsBesides:(WTRowView *)row animated:(BOOL)animated;
- (void)deselectAllRowsAnimated:(BOOL)animated;
- (void)deselectOtherRowsAnimated:(BOOL)animated;
- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)key;
- (void)setTarget:(id)targetObjet action:(SEL)actionSelector;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;

@end

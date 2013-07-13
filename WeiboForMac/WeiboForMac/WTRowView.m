//
//  WTRowView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTRowView.h"
#import "WeiboConstants.h"

@implementation WTRowView
@synthesize isFirst, isLast, isGrouped, rootRow, childRows;
@synthesize rowHeight, selectable, highlighted, selected;
@synthesize menu, dynamicHeight, parentRow, userInfo, delegate;

+ (WTRowView *)row{
    return [[[WTRowView alloc] init] autorelease];
}
+ (WTRowView *)sectionHeader:(NSString *)text{
    WeiboUnimplementedMethod
    return [self row];
}
+ (WTRowView *)spacerRow:(CGFloat)rowHeight{
    WeiboUnimplementedMethod
    return [self row];
}
+ (id)divider:(id)arg1{
    WeiboUnimplementedMethod
    return [self row];
}
+ (WTRowView *)loadingRow{
    WeiboUnimplementedMethod
    return [self row];
}
- (NSMenu *)menuForEvent:(NSEvent *)event{
    WeiboUnimplementedMethod
    return nil;
}
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (id)init{
    return [self initWithFrame:CGRectZero];
}
- (void)dealloc{
    [menu release];
    [userInfo release];
    [childRows release];
    [super dealloc];
}
- (void)beginChanges{
    
}
- (void)endChanges{
    
}
- (void)_childRowsChanged{
    
}
- (NSString *)description{
    WeiboUnimplementedMethod
    return [super description];
}
- (void)_setupFrame:(WTRowView *)rowView{
    
}
- (TUIView *)childContainer{
    WeiboUnimplementedMethod
    return nil;
}
- (void)_add:(WTRowView *)newRow{
    
}
- (void)_remove:(WTRowView *)oldRow{
    
}
- (void)_mightHaveRemovedAllChildren{
    
}
- (WTRowView *)addChildRow:(WTRowView *)newRow{
    WeiboUnimplementedMethod
    return nil;
}
- (void)removeChildRow:(WTRowView *)oldRow{
    
}
- (void)replaceChildRow:(WTRowView *)oldRow withRow:(WTRowView *)newRow{
    
}
- (CGFloat)calculatedRowHeight{
    WeiboUnimplementedMethod
    return 0;
}
- (CGFloat)childWidth:(CGFloat)selfWidth{
    WeiboUnimplementedMethod
    return 0;
}
- (CGFloat)xOffset{
    WeiboUnimplementedMethod
    return 0;
}
- (CGFloat)_updateLayout:(CGFloat)arg1 width:(CGFloat)width xOffset:(CGFloat)xOffset{
    WeiboUnimplementedMethod
    return 0;
}
- (void)layoutSubviews{
    
}
- (void)updateLayout{
    
}
- (void)setFrame:(CGRect)frame{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
}
- (void)setNeedsDisplay{
    
}
- (void)_deselectRowsBesides:(WTRowView *)row animated:(BOOL)animated{
    
}
- (void)deselectAllRowsAnimated:(BOOL)animated{
    
}
- (void)deselectOtherRowsAnimated:(BOOL)animated{
    
}
- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)key{
    WeiboUnimplementedMethod
    return nil;
}
- (void)setTarget:(id)targetObjet action:(SEL)actionSelector{
    
}
- (void)mouseDown:(NSEvent *)event{
    
}
- (void)mouseUp:(NSEvent *)event{
    
}
- (BOOL)acceptsFirstMouse:(NSEvent *)event{
    WeiboUnimplementedMethod
    return YES;
}

@end

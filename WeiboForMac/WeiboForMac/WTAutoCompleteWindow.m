//
//  WTAutocompleteWindow.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-31.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTAutoCompleteWindow.h"
#import "WTAutoCompleteCell.h"
#import "WTCGAdditions.h"

#define BOTTOMBAR_HEIGHT 30.0

@implementation WTAutoCompleteWindow
@synthesize autocompleteType, autocompleteItems, tableView = _tableView, delegate;

- (id)init{
    if (self = [super initWithContentRect:CGRectZero]) {
        [self setHasShadow:YES];
        [self setLevel:NSFloatingWindowLevel];
        
        TUIView * containerView = [[TUIView alloc] initWithFrame:CGRectZero];
        
        containerView.layer.cornerRadius = 6.0;
        containerView.layer.masksToBounds = YES;
        
        [nsView setRootView:containerView];
        [nsView ab_setIsOpaque:NO];
        
        [containerView release];
        
        _tableView = [[TUITableView alloc] initWithFrame:CGRectZero];
        _tableView.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.clipsToBounds = YES;
        _tableView.alwaysBounceVertical = NO;
        _tableView.bounces = NO;
        
        [containerView addSubview:_tableView];
        
        [_tableView  setLayout:^(TUIView * v){
            return v.superview.bounds;
        }];
        
        [_tableView release];
    }
    return self;
}

- (void)dealloc{
    self.autocompleteItems = nil;
    [super dealloc];
}

- (BOOL)useCustomContentView{
    return YES;
}
- (void)drawBackground:(CGRect)rect{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = [self frame];
    b.origin.x = 0;
    b.origin.y = 0;
    
    CGContextClipToRoundRect(ctx, b, 6.0);
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.9);
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, b.size.height));

}
- (NSInteger)tableView:(TUITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [autocompleteItems count];
}
- (CGFloat)cellHeight{
    return 40.0;
}
- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    return [self cellHeight];
}
- (void)tableView:(TUITableView *)tableView didSelectRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    
}
- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event{
    WeiboAutocompleteResultItem * item = [autocompleteItems objectAtIndex:indexPath.row];
    [delegate autoCompleteTableView:tableView didSelectAutoCompleteItem:item];
}
- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    WTAutoCompleteCell * cell = reusableTableCellOfClass(tableView, WTAutoCompleteCell);
    [cell setResult:[autocompleteItems objectAtIndex:indexPath.row]];
    [cell setOpaque:NO];
    return cell;
}
- (void)fitToCellsAtPoint:(CGPoint)point{
    
}
- (void)selectFirstItem{
    if ([autocompleteItems count] == 0) {
        return;
    }
    [_tableView selectRowAtIndexPath:[TUIFastIndexPath indexPathForRow:0 inSection:0] 
                            animated:NO 
                      scrollPosition:TUITableViewScrollPositionTop];
}
- (void)previousItem{
    TUIFastIndexPath * selected = [_tableView indexPathForSelectedRow];
    if (selected.row == 0) {
        return;
    }
    [_tableView selectRowAtIndexPath:[TUIFastIndexPath indexPathForRow:selected.row-1 inSection:0] 
                            animated:YES 
                      scrollPosition:TUITableViewScrollPositionToVisible];
}
- (void)nextItem{
    TUIFastIndexPath * selected = [_tableView indexPathForSelectedRow];
    if (selected.row == [autocompleteItems count] - 1) {
        return;
    }
    [_tableView selectRowAtIndexPath:[TUIFastIndexPath indexPathForRow:selected.row+1 inSection:0] 
                            animated:YES 
                      scrollPosition:TUITableViewScrollPositionToVisible];
}

- (void)flashSelectedItemWithCompletion:(void (^)(BOOL finished))completion
{
    WTAutoCompleteCell * cell = (WTAutoCompleteCell *)[_tableView cellForRowAtIndexPath:_tableView.indexPathForSelectedRow];
    
    if ([cell isKindOfClass:[WTAutoCompleteCell class]])
    {
        [cell setSelected:NO];
        
        dispatch_time_t onTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.075 * NSEC_PER_SEC));
        dispatch_after(onTime, dispatch_get_main_queue(), ^(void){
            [cell setSelected:YES];
            
            dispatch_time_t closeTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.075 * NSEC_PER_SEC));
            
            dispatch_after(closeTime, dispatch_get_main_queue(), ^(void){
                completion(YES);
            });
        });
    }
    else
    {
        completion(YES);
    }
}

@end

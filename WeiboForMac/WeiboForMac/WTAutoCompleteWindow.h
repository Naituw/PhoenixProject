//
//  WTAutocompleteWindow.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-31.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUINSWindow.h"
#import "WTAutoCompleteResultItem.h"

@class TUITableView;

@protocol WTAutoCompleteDelegate;

@interface WTAutoCompleteWindow : TUINSWindow <TUITableViewDelegate, TUITableViewDataSource> {
    NSArray * autocompleteItems;
    TUITableView *_tableView;
    id <WTAutoCompleteDelegate> delegate;
    WeiboAutocompleteType autocompleteType;
}

@property (retain, nonatomic) NSArray * autocompleteItems;
@property (readonly, nonatomic) TUITableView * tableView;
@property (assign, nonatomic) id <WTAutoCompleteDelegate> delegate;
@property (assign, nonatomic) WeiboAutocompleteType autocompleteType;

- (void)fitToCellsAtPoint:(CGPoint)point;
- (void)selectFirstItem;
- (void)previousItem;
- (void)nextItem;
- (void)flashSelectedItemWithCompletion:(void (^)(BOOL finished))completion;

@end

@class WeiboAutocompleteResultItem;

@protocol WTAutoCompleteDelegate <NSObject>

- (void)autoCompleteTableView:(TUITableView *)tableView didSelectAutoCompleteItem:(WeiboAutocompleteResultItem *)item;

@end

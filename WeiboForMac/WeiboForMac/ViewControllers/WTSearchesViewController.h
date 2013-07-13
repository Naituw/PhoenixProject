//
//  WTSearchesViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"
#import "TUITextField.h"
#import "WMGroupedTableViewController.h"

@class WeiboAccount;

@interface WTSearchesViewController : WMGroupedTableViewController 
<TUITextFieldDelegate>{
    TUITextField * textField;
}

@property (retain, nonatomic) WeiboAccount * account;
@property (retain, nonatomic) NSArray * trends;

@end

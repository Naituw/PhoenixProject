//
//  WTRepliesStreamViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTRepliesStreamViewController.h"
#import "WeiboStream.h"
#import "WeiboRepliesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboUser.h"
#import "WTStatusCell.h"
#import "WTHeadImageView.h"
#import "WMCommentsHeaderView.h"
@implementation WTRepliesStreamViewController


- (WeiboRepliesStream *)repliesStream
{
    return (WeiboRepliesStream *)statusStream;
}

- (TUITableViewStyle)tableViewStyle
{
    return TUITableViewStylePlain;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForSectionAtIndex:(NSUInteger)index
{
    if (index == 1) {
        return 0;
    }
    WeiboStatus * baseStatus = [[self repliesStream] baseStatus];
    return [self tableView:_tableView heightForBaseStatus:(WeiboBaseStatus *)baseStatus];
}

- (TUIView *)tableView:(TUITableView *)tableView headerViewForSection:(NSInteger)section
{
    if (section == 1) {
        return nil;
    }
    WeiboStatus * baseStatus = [[self repliesStream] baseStatus];
    WMCommentsHeaderView * header = [[WMCommentsHeaderView alloc] initWithFrame:CGRectMake(0, 0, 200, 70)];
    
    CGFloat currentScaleFactor = TUICurrentContextScaleFactor();
    
    NSString * avatarURLString = (currentScaleFactor > 1) ? baseStatus.user.profileLargeImageUrl : baseStatus.user.profileImageUrl;
    NSURL * avatarURL = [NSURL URLWithString:avatarURLString];
    
    [header.avatar setImageWithURL:avatarURL
                placeholderImage:[TUIImage imageNamed:@"headplaceholder.png" cache:YES]];
    
    TUIAttributedString *s = [TUIAttributedString stringWithString:baseStatus.text];
	s.color = [TUIColor colorWithWhite:0.4 alpha:1.0];
	s.font = [TUIFont fontWithName:@"HelveticaNeue" size:13];
	header.content.attributedString = s;
    return [header autorelease];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![statusStream hasData]) {
        [statusStream loadOlder];
    }
}

- (CGFloat)toolbarViewHeight
{
    return 40;
}

- (BOOL)scrollToTopAutomatically
{
    return NO;
}

@end

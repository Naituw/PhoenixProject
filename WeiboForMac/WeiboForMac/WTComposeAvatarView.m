//
//  WTComposeAvatarView.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposeAvatarView.h"
#import "TUICGAdditions.h"
#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"

@implementation WTComposeAvatarView

- (NSMenu *)defaultMenu
{
    NSMenu * menu = [[NSMenu alloc] initWithTitle:@""];
    
    for (NSInteger index = 0; index < [[[Weibo sharedWeibo] accounts] count]; index++)
    {
        WeiboAccount * account = [[Weibo sharedWeibo] accounts][index];
        
        NSMenuItem * item = [[[NSMenuItem alloc] initWithTitle:@"" action:@selector(switchAccount:) keyEquivalent:@""] autorelease];
        item.target = self;
        item.tag = index;
        item.image = account.profileImage;
        
        [menu addItem:item];
    }
    
    [menu setAutoenablesItems:YES];
    
    return [menu autorelease];
}

- (void)switchAccount:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSInteger index = [sender tag];
        self.selectedAccountIndex = index;
    }
}

- (WeiboAccount *)selectedAccount
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if (self.selectedAccountIndex >= 0 &&
        self.selectedAccountIndex < accounts.count)
    {
        return accounts[self.selectedAccountIndex];
    }
    return nil;
}

- (void)setSelectedAccountIndex:(NSInteger)selectedAccountIndex
{
    _selectedAccountIndex = selectedAccountIndex;
    
    [self setNeedsDisplay];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    if ([[[Weibo sharedWeibo] accounts] count] <= 1)
    {
        return;
    }
    
    NSMenu * menu = [self defaultMenu];
    
    NSMenuItem * item = menu.itemArray[self.selectedAccountIndex];
    NSPoint point = NSZeroPoint;
    point.y += self.bounds.size.height + 1;
    point.x -= (92.0 - self.bounds.size.width) / 2;
    
    [menu popUpMenuPositioningItem:item atLocation:point inView:self];
}

- (void)drawRect:(NSRect)dirtyRect{
    CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRoundRect(ctx, dirtyRect, 4.0);
    
    NSImage * image = [[self selectedAccount] profileImage];
    [image drawInRect:dirtyRect fromRect:dirtyRect operation:NSCompositeCopy fraction:1.0];
}

@end

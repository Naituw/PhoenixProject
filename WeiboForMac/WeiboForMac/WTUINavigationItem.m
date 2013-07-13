//
//  WTUINavigationItem.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationItem.h"
#import "WTUIBarButtonItem.h"
#import "WTUINavigationItem+UIPrivate.h"
#import "WTUINavigationBar.h"
#import "WTUINavigationBar+UIPrivate.h"

static void * const UINavigationItemContext = "UINavigationItemContext";

@implementation WTUINavigationItem
@synthesize title=_title, rightBarButtonItem=_rightBarButtonItem, titleView=_titleView, hidesBackButton=_hidesBackButton;
@synthesize leftBarButtonItem=_leftBarButtonItem, backBarButtonItem=_backBarButtonItem, prompt=_prompt;

+ (NSSet *)_keyPathsTriggeringUIUpdates
{
    static NSSet * __keyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __keyPaths = [[NSSet alloc] initWithObjects:@"title", @"prompt", @"backBarButtonItem", @"leftBarButtonItem", @"rightBarButtonItem", @"titleView", @"hidesBackButton", nil];
    });
    return __keyPaths;
}

- (id)initWithTitle:(NSString *)theTitle
{
    if ((self=[super init])) {
        self.title = theTitle;
    }
    return self;
}

- (void)dealloc
{
    // removes automatic observation
    [self _setNavigationBar:nil];
    
    [_backBarButtonItem release];
    [_leftBarButtonItem release];
    [_rightBarButtonItem release];
    [_title release];
    [_titleView release];
    [_prompt release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != UINavigationItemContext) {
        if ([[self superclass] instancesRespondToSelector:_cmd])
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    [[self _navigationBar] _updateNavigationItem:self animated:NO];
}

- (void)_setNavigationBar:(WTUINavigationBar *)navigationBar
{
    // weak reference
    if (_navigationBar == navigationBar)
        return;
    
    if (_navigationBar != nil && navigationBar == nil) {
        // remove observation
        for (NSString * keyPath in [[self class] _keyPathsTriggeringUIUpdates]) {
            [self removeObserver:self forKeyPath:keyPath];
        }
    }
    else if (navigationBar != nil) {
        // observe property changes to notify UI element
        for (NSString * keyPath in [[self class] _keyPathsTriggeringUIUpdates]) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:UINavigationItemContext];
        }
    }
    
    _navigationBar = navigationBar;
}

- (WTUINavigationBar *)_navigationBar
{
    return _navigationBar;
}

- (void)setLeftBarButtonItem:(WTUIBarButtonItem *)item animated:(BOOL)animated
{
    if (item != _leftBarButtonItem) {
        [self willChangeValueForKey: @"leftBarButtonItem"];
        [_leftBarButtonItem release];
        _leftBarButtonItem = [item retain];
        [self didChangeValueForKey: @"leftBarButtonItem"];
    }
}

- (void)setLeftBarButtonItem:(WTUIBarButtonItem *)item
{
    [self setLeftBarButtonItem:item animated:NO];
}

- (void)setRightBarButtonItem:(WTUIBarButtonItem *)item animated:(BOOL)animated
{
    if (item != _rightBarButtonItem) {
        [self willChangeValueForKey: @"rightBarButtonItem"];
        [_rightBarButtonItem release];
        _rightBarButtonItem = [item retain];
        [self didChangeValueForKey: @"rightBarButtonItem"];
    }
}

- (void)setRightBarButtonItem:(WTUIBarButtonItem *)item
{
    [self setRightBarButtonItem:item animated:NO];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated
{
    [self willChangeValueForKey: @"hidesBackButton"];
    _hidesBackButton = hidesBackButton;
    [self didChangeValueForKey: @"hidesBackButton"];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
    [self setHidesBackButton:hidesBackButton animated:NO];
}

- (WTUIBarButtonItem *)backBarButtonItem
{
    if (_backBarButtonItem) {
        return _backBarButtonItem;
    } else {
        return [[[WTUIBarButtonItem alloc] initWithTitle:(self.title ?: @"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    }
}

@end

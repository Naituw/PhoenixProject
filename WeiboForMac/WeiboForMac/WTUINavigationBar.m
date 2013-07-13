//
//  WTUINavigationBar.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationBar.h"
#import "WTUINavigationBar+UIPrivate.h"
#import "UIGraphics.h"
#import "TUIColor.h"
#import "TUILabel.h"
#import "WTUINavigationItem.h"
#import "WTUINavigationItem+UIPrivate.h"
#import "TUIFont.h"
#import "TUIImage+UIPrivate.h"
#import "WTUIBarButtonItem.h"
#import "TUIButton.h"
#import "TUIView+WTAddition.h"
#import "WTUILableView.h"
#import "WTUILabel.h"
#import "WTUINavigationBarBackButton.h"

static const TUIEdgeInsets kButtonEdgeInsets = {0,0,0,0};
static const CGFloat kMinButtonWidth = 30;
static const CGFloat kMaxButtonWidth = 200;
static const CGFloat kMaxButtonHeight = 24;

static const NSTimeInterval kAnimationDuration = 0.3;

typedef enum {
    _UINavigationBarTransitionPush,
    _UINavigationBarTransitionPop,
    _UINavigationBarTransitionReload		// explicitly tag reloads from changed UINavigationItem data
} _UINavigationBarTransition;

@implementation WTUINavigationBar
@synthesize tintColor=_tintColor, delegate=_delegate, items=_navStack;

+ (void)_setBarButtonSize:(TUIView *)view
{
    CGRect frame = view.frame;
    frame.size = [view sizeThatFits:CGSizeMake(kMaxButtonWidth,kMaxButtonHeight)];
    frame.size.height = kMaxButtonHeight;
    frame.size.width = MAX(frame.size.width,kMinButtonWidth);
    view.frame = frame;
}

+ (TUIButton *)_backButtonWithBarButtonItem:(WTUIBarButtonItem *)item
{
    if (!item) return nil;
    
    WTUINavigationBarBackButton *backButton = [[WTUINavigationBarBackButton alloc] initWithString:item.title];
    // add action here
    return [backButton autorelease];
}

+ (TUIView *)_viewWithBarButtonItem:(WTUIBarButtonItem *)item
{
    if (!item) return nil;
    
    if (item.customView) {
        [self _setBarButtonSize:item.customView];
        return item.customView;
    } else {
        TUIButton *button = [TUIButton buttonWithType:TUIButtonTypeCustom];
        [button setBackgroundImage:[TUIImage _toolbarButtonImage] forState:TUIControlStateNormal];
        [button setBackgroundImage:[TUIImage _highlightedToolbarButtonImage] forState:TUIControlStateHighlighted];
        [button setTitle:item.title forState:TUIControlStateNormal];
        [button setImage:item.image forState:TUIControlStateNormal];
        button.titleLabel.font = [TUIFont systemFontOfSize:11];
        button.imageEdgeInsets = TUIEdgeInsetsMake(0,7,0,7);
        [button addTarget:item.target action:item.action forControlEvents:TUIControlEventTouchUpInside];
        [self _setBarButtonSize:button];
        return button;
    }
}

- (id)init{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _navStack = [[NSMutableArray alloc] init];
        //self.backgroundColor = [TUIColor clearColor];
        //self.tintColor = [TUIColor colorWithRed:21/255.f green:21/255.f blue:25/255.f alpha:1];
    }
    return self;
}

- (void)dealloc
{
    [self.topItem _setNavigationBar: nil];
    [_navStack release];
    [_tintColor release];
    [super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
    _delegate = newDelegate;
    _delegateHas.shouldPushItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPushItem:)];
    _delegateHas.didPushItem = [_delegate respondsToSelector:@selector(navigationBar:didPushItem:)];
    _delegateHas.shouldPopItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPopItem:)];
    _delegateHas.didPopItem = [_delegate respondsToSelector:@selector(navigationBar:didPopItem:)];
}

- (WTUINavigationItem *)topItem
{
    return [_navStack lastObject];
}

- (WTUINavigationItem *)backItem
{
    return ([_navStack count] <= 1)? nil : [_navStack objectAtIndex:[_navStack count]-2];
}

- (void)_backButtonTapped:(id)sender
{
    [self popNavigationItemAnimated:YES];
}

- (void)_removeAnimatedViews:(NSArray *)views
{
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
}




- (void)_setViewsWithTransition:(_UINavigationBarTransition)transition animated:(BOOL)animated
{
    CGFloat textPosition = [(WTUILableView *)_centerView textPositionX];
    {
        //NSLog(@"settting,self.bounds.width:%f",self.bounds.size.width);
        if (self.bounds.size.width == 0) {
            self.bounds = CGRectMake(0, 0, 300, 36);
        }
        
        NSMutableArray *previousViews = [[NSMutableArray alloc] init];
        
        if (_leftView) [previousViews addObject:_leftView];
        if (_centerView) [previousViews addObject:_centerView];
        if (_rightView) [previousViews addObject:_rightView];
        
        //CGRect backButtonRect = CGRectMake(70, 0, 60, 25);
        
        if (animated) {
            
            //CGFloat moveCenterBy = self.bounds.size.width - _centerView.frame.origin.x;
            //CGFloat moveLeftBy = self.bounds.size.width * 0.2f;
            CGRect centerDes;
            CGRect leftDes;
            if (transition == _UINavigationBarTransitionPush) {
                centerDes = CGRectOffset(_centerView?_centerView.frame:CGRectZero,
                                         74.0f - textPosition, 0);
                leftDes = _leftView?_leftView.bounds:CGRectZero;
            }
            else if(transition == _UINavigationBarTransitionPop){
                centerDes = CGRectMake(self.frame.size.width, 0, _centerView.frame.size.width, 36);
                
                leftDes = CGRectMake(self.bounds.size.width/2 - 50, 0, _leftView.frame.size.width, 36);
            }
            else{
                centerDes = _centerView?_centerView.frame:CGRectZero;
                leftDes = _leftView?_leftView.frame:CGRectZero;
            }
            
            [_leftView removeFromSuperview];
            [self addSubview:_leftView];
            
            [TUIView animateWithDuration:kAnimationDuration
                             animations:^(void) {
                                 _leftView.frame = leftDes;
                                 //CGRectOffset(_leftView.frame, moveLeftBy, 0);
                                 _centerView.frame = centerDes;
                                 //CGRectOffset(_centerView.frame, moveCenterBy, 0);
                             }
                              completion:NULL];
            
            [TUIView animateWithDuration:kAnimationDuration * 1.0
                                   delay:kAnimationDuration * 0.0 
                                   curve:TUIViewAnimationCurveEaseIn
                             animations:^(void) {
                                 _leftView.alpha = 0;
                                 _rightView.alpha = 0;
                                 _centerView.alpha = 0;
                             }
                              completion:^(BOOL finished) {
                                  [self _removeAnimatedViews:previousViews];
                              }];
            
            
        } else {
            [self _removeAnimatedViews:previousViews];
        }
        
        [previousViews release];
    }
    
    WTUINavigationItem *topItem = self.topItem;
    
    if (topItem) {
        WTUINavigationItem *backItem = self.backItem;
        
        // update weak references
        [backItem _setNavigationBar: nil];
        [topItem _setNavigationBar: self];
        
        //CGRect leftFrame = CGRectZero;
        CGRect rightFrame = CGRectZero;
        
        if (backItem) {
            _leftView = [[self class] _backButtonWithBarButtonItem:backItem.backBarButtonItem];
            CGRect backFrame = CGRectMake(70, 0, 64, 36);
            _leftView.frame = backFrame;
        } else {
            _leftView = [[self class] _viewWithBarButtonItem:topItem.leftBarButtonItem];
        }
        
        if (_leftView) {
            //leftFrame = _leftView.frame;
            //leftFrame.origin = CGPointMake(kButtonEdgeInsets.left, kButtonEdgeInsets.top);
            //_leftView.frame = leftFrame;
            [self addSubview:_leftView];
        }
        
        _rightView = [[self class] _viewWithBarButtonItem:topItem.rightBarButtonItem];
        
        if (_rightView) {
            _rightView.autoresizingMask = TUIViewAutoresizingFlexibleLeftMargin;
            rightFrame = _rightView.frame;
            rightFrame.origin.x = self.bounds.size.width-rightFrame.size.width - kButtonEdgeInsets.right;
            rightFrame.origin.y = kButtonEdgeInsets.top;
            _rightView.frame = rightFrame;
            [self addSubview:_rightView];
        }
        
        _centerView = topItem.titleView;
        if (!_centerView) {
            WTUILableView * titleLabel = [[[WTUILableView alloc] initWithString:topItem.title fontSize:13.0] autorelease];
            _centerView = titleLabel;
        }
        
        //const CGFloat centerPadding = MAX(leftFrame.size.width, rightFrame.size.width);
        const CGFloat leftPadding = _leftView? 140.0f:70.0f;
        const CGFloat rightPadding = 70.0f;
        _centerView.autoresizingMask = TUIViewAutoresizingFlexibleWidth;
        
        _centerView.frame = CGRectMake(leftPadding,0,self.bounds.size.width-leftPadding-rightPadding,36);
        [self addSubview:_centerView];
        [_centerView redraw];
        CGFloat newTextPosition = [(WTUILableView *)_centerView textPositionX];
        if (animated) {

            
            CGRect leftStart,centerStart ,leftEnd = _leftView.frame ,centerEnd = _centerView.frame;
            if (transition == _UINavigationBarTransitionPush) {
                leftStart = CGRectOffset(_leftView.frame, textPosition - 74.0f, 0);
                centerStart = CGRectOffset(_centerView.bounds, self.bounds.size.width, 0);
            }
            else if(transition == _UINavigationBarTransitionPop){
                leftStart = CGRectOffset(_leftView.bounds, -_leftView.bounds.size.width, 0);
                centerStart = CGRectOffset(_centerView.bounds, 74-newTextPosition+_centerView.frame.origin.x, 0);
            }
            else{
                centerStart = _centerView.frame;
                leftStart = _leftView.frame;
            }
            
            [CATransaction begin];
            _leftView.frame = leftStart;
            _centerView.frame = centerStart;
            _leftView.alpha = 0;
            _rightView.alpha = 0;
            _centerView.alpha = 0;
            [CATransaction flush];
            [CATransaction commit];
            
            [TUIView animateWithDuration:kAnimationDuration
                             animations:^(void) {
                                 _leftView.frame = leftEnd;
                                 _centerView.frame = centerEnd;
                             }
                              completion:NULL];
            
            [TUIView animateWithDuration:kAnimationDuration * 1.0
                                   delay:kAnimationDuration * 0
                                   curve:TUIViewAnimationCurveEaseIn
                             animations:^(void) {
                                 _leftView.alpha = 1;
                                 _rightView.alpha = 1;
                                 _centerView.alpha = 1;
                             }
                             completion:NULL];
        }
    } else {
        _leftView = _centerView = _rightView = nil;
    }
}

- (void)setTintColor:(TUIColor *)newColor
{
    if (newColor != _tintColor) {
        [_tintColor release];
        _tintColor = [newColor retain];
        [self setNeedsDisplay];
    }
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    if (![_navStack isEqualToArray:items]) {
        [_navStack removeAllObjects];
        [_navStack addObjectsFromArray:items];
        [self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
    }
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items animated:NO];
}

- (void)setItemWithFade:(WTUINavigationItem *)item{
    if ([_navStack count] >= 1) {
        [_navStack removeAllObjects];
        [_navStack addObject:item];
        [self _setViewsWithTransition:_UINavigationBarTransitionReload animated:YES];
    }
}

- (UIBarStyle)barStyle
{
    return UIBarStyleDefault;
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
}

- (void)pushNavigationItem:(WTUINavigationItem *)item animated:(BOOL)animated
{
    BOOL shouldPush = YES;
    
    if (_delegateHas.shouldPushItem) {
        shouldPush = [_delegate navigationBar:self shouldPushItem:item];
    }
    
    if (shouldPush) {
        [_navStack addObject:item];
        [self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
        
        if (_delegateHas.didPushItem) {
            [_delegate navigationBar:self didPushItem:item];
        }
    }
}

- (WTUINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    WTUINavigationItem *previousItem = self.topItem;
    
    if (previousItem) {
        BOOL shouldPop = YES;
        
        if (_delegateHas.shouldPopItem) {
            shouldPop = [_delegate navigationBar:self shouldPopItem:previousItem];
        }
        
        if (shouldPop) {
            [previousItem retain];
            [_navStack removeObject:previousItem];
            [self _setViewsWithTransition:_UINavigationBarTransitionPop animated:animated];
            
            if (_delegateHas.didPopItem) {
                [_delegate navigationBar:self didPopItem:previousItem];
            }
            
            return [previousItem autorelease];
        }
    }
    
    return nil;
}

- (void)_updateNavigationItem:(WTUINavigationItem *)item animated:(BOOL)animated	// ignored for now
{
    // let's sanity-check that the item is supposed to be talking to us
    if (item != self.topItem) {
        [item _setNavigationBar:nil];
        return;
    }
    
    // this is going to remove & re-add all the item views. Not ideal, but simple enough that it's worth profiling.
    // next step is to add animation support-- that will require changing _setViewsWithTransition:animated:
    //  such that it won't perform any coordinate translations, only fade in/out
    
    // don't just fire the damned thing-- set a flag & mark as needing layout
    if (_navigationBarFlags.reloadItem == 0) {
        _navigationBarFlags.reloadItem = 1;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_navigationBarFlags.reloadItem) {
        _navigationBarFlags.reloadItem = 0;
        [self _setViewsWithTransition:_UINavigationBarTransitionReload animated:NO];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_centerView) {
        _centerView.alpha = [[self nsWindow] isKeyWindow]?1.0:0.5;
    }
    
    if (_leftView) {
        _leftView.alpha = [[self nsWindow] isKeyWindow]?1.0:0.5;
    }
    //const CGRect bounds = self.bounds;
    
    // I kind of suspect that the "right" thing to do is to draw the background and then paint over it with the tintColor doing some kind of blending
    // so that it actually doesn "tint" the image instead of define it. That'd probably work better with the bottom line coloring and stuff, too, but
    // for now hardcoding stuff works well enough.
    
    //[_tintColor setFill];
    //UIRectFill(bounds);
}

- (void)redraw{
    [super redraw];
    if (_centerView) {
        [_centerView redraw];
    }
    if (_leftView) {
        [_leftView redraw];
    }
}

-(void)mouseDown:(NSEvent *)theEvent {    
    [super mouseDown:theEvent];
    if ([self superview]) {
        [[self superview] mouseDown:theEvent];
    }

}

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    if ([self superview]) {
        [[self superview] mouseDragged:theEvent];
    }
}


@end

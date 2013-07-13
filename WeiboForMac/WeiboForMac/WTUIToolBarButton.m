//
//  WTUIToolBarButton.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIToolbarButton.h"
#import "WTUIBarButtonItem.h"
#import "TUIImage+UIPrivate.h"
#import "TUILabel.h"
#import "TUIFont.h"

// I don't like most of this... the real toolbar button lays things out different than a default button.
// It also seems to have some padding built into it around the whole thing (even the background)
// It centers images vertical and horizontal if not bordered, but it appears to be top-aligned if it's bordered
// If you specify both an image and a title, these buttons stack them vertically which is unlike default UIButton behavior
// This is all a pain in the ass and wrong, but good enough for now, I guess

static TUIEdgeInsets TUIToolbarButtonInset = {0,4,0,4};

@implementation WTUIToolbarButton

- (id)initWithBarButtonItem:(WTUIBarButtonItem *)item
{
    CGRect frame = CGRectMake(0,0,24,24);
    
    if ((self=[super initWithFrame:frame])) {
        TUIImage *image = nil;
        NSString *title = nil;
        
        if (item->_isSystemItem) {
            switch (item->_systemItem) {
                case UIBarButtonSystemItemAdd:
                    image = [TUIImage _buttonBarSystemItemAdd];
                    break;
                    
                case UIBarButtonSystemItemReply:
                    image = [TUIImage _buttonBarSystemItemReply];
                    break;
                    
                default:
                    break;
            }
        } else {
            image = [item.image _toolbarImage];
            title = item.title;
            
            if (item.style == UIBarButtonItemStyleBordered) {
                self.titleLabel.font = [TUIFont systemFontOfSize:11];
                [self setBackgroundImage:[TUIImage _toolbarButtonImage] forState:TUIControlStateNormal];
                [self setBackgroundImage:[TUIImage _highlightedToolbarButtonImage] forState:TUIControlStateHighlighted];
                self.imageEdgeInsets = TUIEdgeInsetsMake(0,7,0,7);
                self.titleEdgeInsets = TUIEdgeInsetsMake(4,0,0,0);
                self.clipsToBounds = YES;
            }
        }
        
        [self setImage:image forState:TUIControlStateNormal];
        [self setTitle:title forState:TUIControlStateNormal];
        [self addTarget:item.target action:item.action forControlEvents:TUIControlEventTouchUpInside];
        
        // resize the view to fit according to the rules, which appear to be that if the width is set directly in the item, use that
        // value, otherwise size to fit - but cap the total height, I guess?
        CGSize fitToSize = frame.size;
        
        if (item.width > 0) {
            frame.size.width = item.width;
        } else {
            frame.size.width = [self sizeThatFits:fitToSize].width;
        }
        
        self.frame = frame;
    }
    return self;
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return TUIEdgeInsetsInsetRect(bounds, TUIToolbarButtonInset);
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    return TUIEdgeInsetsInsetRect(bounds, TUIToolbarButtonInset);
}

- (CGSize)sizeThatFits:(CGSize)fitSize
{
    fitSize = [super sizeThatFits:fitSize];
    fitSize.width += TUIToolbarButtonInset.left + TUIToolbarButtonInset.right;
    fitSize.height += TUIToolbarButtonInset.top + TUIToolbarButtonInset.bottom;
    return fitSize;
}

@end

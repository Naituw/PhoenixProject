//
//  WTAlertView.h
//  WeiboForMac
//
//  Created by Wutian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TUIView.h"
#define BAR_HEIGHT 24.0f
#define BAR_SHADOW 6.0f

@class TUITextRenderer;

typedef enum {
	WTAlertStyleTip,        
	WTAlertStyleError,    
	WTAlertStyleWarning
} WTAlertStyle;

@interface WTAlertView : WUIView {
    TUITextRenderer * _title;
    WTAlertStyle _style;
}

- (id)initWithTitle:(NSString *)title style:(WTAlertStyle)style;

@end

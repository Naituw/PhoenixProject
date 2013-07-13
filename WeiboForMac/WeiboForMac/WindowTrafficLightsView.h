//
//  WindowTrafficLightsView.h
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@protocol WindowTrafficLightsViewDelegate;

@interface WindowTrafficLightsView : WUIView <TUIViewDelegate>

@property (nonatomic, assign) id<WindowTrafficLightsViewDelegate> delegate;

@end

@protocol WindowTrafficLightsViewDelegate <NSObject>

- (void)trafficClose:(id)sender;
- (void)trafficMinimize:(id)sender;
- (void)trafficZoom:(id)sender;

@end


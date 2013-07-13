//
//  WeiboEmotionManager.m
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboEmotionManager.h"
#import "WeiboEmotion.h"
#import "WTFileManager.h"
#import "ASIHttpRequest.h"
#import "ASINetworkQueue.h"

@interface WeiboEmotionManager ()
@property (nonatomic, assign) BOOL filesReady;
@property (nonatomic, readonly) BOOL htmlReady;
@property (nonatomic, retain) ASINetworkQueue * downloadQueue;
@end

@implementation WeiboEmotionManager
@synthesize derivedHTML = _derivedHTML, emotions = _emotions;
@synthesize filesReady = _filesReady, downloadQueue = _downloadQueue;

- (void)dealloc{
    [_derivedHTML release];
    [_emotions release];
    [_downloadQueue release];
    [super dealloc];
}
+ (WeiboEmotionManager *)sharedManager{
    static WeiboEmotionManager * _sharedManager;
    @synchronized(self){
        if (!_sharedManager) {
            _sharedManager = [[WeiboEmotionManager alloc] init];
            [_sharedManager loadEmotions];
        }
        return _sharedManager;
    }
}

- (BOOL)htmlReady{
    return self.derivedHTML?YES:NO;
}
- (BOOL)ready{
    return self.htmlReady && self.filesReady;
}
- (NSURL *)url{
    NSString * emojiDicetory = [WTFileManager subCacheDirectory:@"emoji"];
    NSString * indexPath = [emojiDicetory stringByAppendingPathComponent:@"index.html"];
    return [NSURL URLWithString:indexPath];
}

- (void)loadEmotions{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString * jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotions" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
        NSArray * emotions = [WeiboEmotion emotionsWithJSON:jsonString];
        NSMutableArray * commonEmotions = [NSMutableArray array];
        for (WeiboEmotion * e in emotions) {
            if (e.common) {
                [commonEmotions addObject:e];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.emotions = commonEmotions;
            [self downloadFiles];
            [self generateHTML];
        });
    });
}
- (void)generateHTML{
    NSString * css = @"*{padding: 0;margin: 0;}#container{width: 404px;list-style: none;border: 1px solid #fff;border-right: none;border-bottom: none;}#container li{display: block;width: 22px;height: 22px;padding: 4px;border: 1px solid #eee;margin: -1px 0 0 -1px;float: left;z-index: 10;position: relative;background: transparent;}#container li:hover{border-color:#a0bdf9;box-shadow: 0px 0px 3px #a0bdf9;z-index: 20;}#container li:active{border-color:#a0bdf9;box-shadow: inset 0px 1px 3px #a0bdf9;z-index: 20;}";
    NSString * emojiDirectory = [WTFileManager subCacheDirectory:@"emoji"];
    [css writeToFile:[emojiDirectory stringByAppendingPathComponent:@"emoji.css"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    NSMutableString * html = [NSMutableString stringWithString:@"<!DOCTYPE html><html><head><meta charset='UTF-8'/><link rel='stylesheet' href='emoji.css'/></head><body><ul id='container'>"];
    for (WeiboEmotion * emotion in self.emotions) {
        [html appendFormat:@"<li onClick=\"window.AppController.emotionClicked_('%@');\"><img src=\"files/%@\"/></li>",emotion.phrase,emotion.fileName];
    }
    [html appendFormat:@"</ul></body></html>"];
    [html writeToFile:[emojiDirectory stringByAppendingPathComponent:@"index.html"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    self.derivedHTML = html;
}
- (void)downloadFiles{
    self.downloadQueue = [ASINetworkQueue queue];
    self.downloadQueue.delegate = self;
    self.downloadQueue.queueDidFinishSelector = @selector(downloadFinished);
    NSString * fileDirectory = [WTFileManager subCacheDirectory:@"emoji/files"];
    for (WeiboEmotion * e in self.emotions) {
        NSString * path = [fileDirectory stringByAppendingPathComponent:e.fileName];
        if ([WTFileManager fileExist:path]) {
            continue;
        }
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:e.url]];
        [request setDownloadDestinationPath:path];
        [self.downloadQueue addOperation:request];
    }
    if (self.downloadQueue.requestsCount == 0) {
        self.filesReady = YES;
    }else {
        [self.downloadQueue go];
    }
}
- (void)downloadFinished{
    self.filesReady = YES;
}

@end

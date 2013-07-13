//
//  WTImageRequest.h
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface WTImageRequest : ASIHTTPRequest {
    NSURL * saveURL;
}
@property (retain) NSURL * saveURL;
@end

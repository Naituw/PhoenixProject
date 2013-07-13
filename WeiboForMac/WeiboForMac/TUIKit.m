/*
 Copyright 2011 Twitter, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "TUIKit.h"

BOOL AtLeastLion = NO;

CGContextRef TUIGraphicsGetCurrentContext(void)
{
	return (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
}

void TUIGraphicsPushContext(CGContextRef context)
{
	NSGraphicsContext *c = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:c];
}

void TUIGraphicsPopContext(void)
{
	[NSGraphicsContext restoreGraphicsState];
}

TUIImage* TUIGraphicsContextGetImage(CGContextRef ctx)
{
	return [TUIImage imageWithCGImage:TUICGImageFromBitmapContext(ctx)];
}

void TUIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
{
	size.width *= scale;
	size.height *= scale;
	if(size.width < 1) size.width = 1;
	if(size.height < 1) size.height = 1;
	CGContextRef ctx = TUICreateGraphicsContextWithOptions(size, opaque);
	TUIGraphicsPushContext(ctx);
	CGContextRelease(ctx);
}

void TUIGraphicsBeginImageContext(CGSize size)
{
	TUIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
}

TUIImage* TUIGraphicsGetImageFromCurrentImageContext(void)
{
	return TUIGraphicsContextGetImage(TUIGraphicsGetCurrentContext());
}

TUIImage* TUIGraphicsGetImageForView(TUIView *view)
{
    CGFloat scale = view.layer.contentsScale;
	TUIGraphicsBeginImageContextWithOptions(view.frame.size, NO, scale);
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    if (scale != 1.0)
    {
        CGContextScaleCTM(ctx, scale, scale);
    }
	[view.layer renderInContext:TUIGraphicsGetCurrentContext()];
	TUIImage *image = TUIGraphicsGetImageFromCurrentImageContext();
	TUIGraphicsEndImageContext();
	return image;
}

void TUIGraphicsEndImageContext(void)
{
	TUIGraphicsPopContext();
}

TUIImage *TUIGraphicsDrawAsImageWithScale(CGSize size, CGFloat scale, void(^draw)(void))
{
    TUIGraphicsBeginImageContextWithOptions(size, NO, scale);
	draw();
	TUIImage *image = TUIGraphicsGetImageFromCurrentImageContext();
	TUIGraphicsEndImageContext();
	return image;
}

TUIImage *TUIGraphicsDrawAsImage(CGSize size, void(^draw)(void))
{
    return TUIGraphicsDrawAsImageWithScale(size, 1, draw);
}

NSData* TUIGraphicsDrawAsPDF(CGRect *optionalMediaBox, void(^draw)(CGContextRef))
{
	NSMutableData *data = [NSMutableData data];
	CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);
	CGContextRef ctx = CGPDFContextCreate(dataConsumer, optionalMediaBox, NULL);
	CGPDFContextBeginPage(ctx, NULL);
	TUIGraphicsPushContext(ctx);
	draw(ctx);
	TUIGraphicsPopContext();
	CGPDFContextEndPage(ctx);
	CGPDFContextClose(ctx);
	CGContextRelease(ctx);
	CGDataConsumerRelease(dataConsumer);
	return data;
}

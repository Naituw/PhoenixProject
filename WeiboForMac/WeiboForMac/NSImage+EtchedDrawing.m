//
//  NSImage+EtchedDrawing.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "NSImage+EtchedDrawing.h"

@implementation NSImage (EtchedImageDrawing)

- (void)drawEtchedInRect:(NSRect)rect
{
    //NSSize size = rect.size;
    //CGFloat dropShadowOffsetY = size.width <= 64.0 ? -1.0 : -2.0;
    //CGFloat innerShadowBlurRadius = size.width <= 32.0 ? 1.0 : 4.0;
    
    CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
    
    //save the current graphics state
    CGContextSaveGState(c);
    
    //Create mask image:
    NSRect maskRect = rect;
    CGImageRef maskImage = [self CGImageForProposedRect:&maskRect context:[NSGraphicsContext currentContext] hints:nil];
    
    //Draw image and white drop shadow:
    /*
    CGContextSetShadowWithColor(c, CGSizeMake(0, dropShadowOffsetY), 0, CGColorGetConstantColor(kCGColorWhite));
    [self drawInRect:maskRect fromRect:NSMakeRect(0, 0, self.size.width, self.size.height) operation:NSCompositeSourceOver fraction:1.0];
     */
    
    //Clip drawing to mask:
    CGContextClipToMask(c, NSRectToCGRect(maskRect), maskImage);
    
    //Draw gradient:
    NSGradient *gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.7 alpha:1.0]
                                                          endingColor:[NSColor colorWithDeviceWhite:0.5 alpha:1.0]] autorelease];
    [gradient drawInRect:maskRect angle:90.0];
    
    /*
    CGContextSetShadowWithColor(c, CGSizeMake(0, -1), innerShadowBlurRadius, CGColorGetConstantColor(kCGColorBlack));
    
    //Draw inner shadow with inverted mask:
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef maskContext = CGBitmapContextCreate(NULL, CGImageGetWidth(maskImage), CGImageGetHeight(maskImage), 8, CGImageGetWidth(maskImage) * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(maskContext, kCGBlendModeXOR);
    CGContextDrawImage(maskContext, maskRect, maskImage);
    CGContextSetRGBFillColor(maskContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(maskContext, maskRect);
    CGImageRef invertedMaskImage = CGBitmapContextCreateImage(maskContext);
    CGContextDrawImage(c, maskRect, invertedMaskImage);
    CGImageRelease(invertedMaskImage);
    CGContextRelease(maskContext);
    */
    //restore the graphics state
    CGContextRestoreGState(c);
}

@end
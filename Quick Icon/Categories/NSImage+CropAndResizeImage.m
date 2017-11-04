//
//  NSImage+CropAndResizeImage.m
//  Quick Icon
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "NSImage+CropAndResizeImage.h"

@implementation NSImage (CropAndResizeImage)

-(NSImage *)cropAndResizeImage:(CGSize)newSize
{
	if (!self.isValid)
		return nil;
	
	// Caclulate the scale that should be used to calculate result
	CGFloat s = newSize.width/newSize.height > self.size.width/self.size.height ? self.size.width/newSize.width : self.size.height/newSize.height;
	// Center of the target size
	CGPoint c = CGPointMake(newSize.width*0.5, newSize.height*0.5);

	// The variables needed for cropping
	CGFloat x = 0;				// X Position shift
	CGFloat y = 0;				// Y Position shift
	CGFloat w = c.x * s * 2;	// Result Width
	CGFloat h = c.y * s * 2;	// Result Height
	
	if (w > h) {
		x = (h-w)*0.5;
	} else {
		y = (w-h)*0.5;
	}
	
	NSRect rect = NSMakeRect(x, y, w, h);
	
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
							 initWithBitmapDataPlanes:NULL
							 pixelsWide:newSize.width
							 pixelsHigh:newSize.height
							 bitsPerSample:8
							 samplesPerPixel:4
							 hasAlpha:YES
							 isPlanar:NO
							 colorSpaceName:NSCalibratedRGBColorSpace
							 bytesPerRow:0
							 bitsPerPixel:0];
	rep.size = newSize;
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
	[self drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:rect operation:NSCompositingOperationCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
	[newImage addRepresentation:rep];
	return newImage;
	
}

@end

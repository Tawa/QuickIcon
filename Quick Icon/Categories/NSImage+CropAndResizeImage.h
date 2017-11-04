//
//  NSImage+CropAndResizeImage.h
//  Quick Icon
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (CropAndResizeImage)

-(NSImage *)cropAndResizeImage:(CGSize)newSize;

@end

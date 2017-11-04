//
//  TargetImageView.m
//  Quick Icon
//
//  Created by Tawa Nicolas on 16/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TargetImageView.h"
#import "NSImage+CropAndResizeImage.h"


@implementation TargetImageView

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		// Register for receiving images.
		[self registerForDraggedTypes:[NSImage imageTypes]];
		
		// Add 1 point border;
		[self highlightBorders:NO];
		
		// Create layer in order to support Aspect-Fill behavior, for cropping results.
		self.layer = [CALayer new];
		self.layer.contentsGravity = kCAGravityResizeAspectFill;
		self.layer.masksToBounds = YES;
		self.wantsLayer = YES;
	}
	return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	// Check if the dragged file is an image and highlight the borders
	if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] && [sender draggingSourceOperationMask] & NSDragOperationCopy)
	{
		[self highlightBorders:YES];
		
		return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
	// Remove highlight on drag exit.
	[self highlightBorders:NO];
}

-(void)highlightBorders:(BOOL)highlight
{
	if (highlight) {
		self.layer.borderWidth = 5;
		self.layer.borderColor = [[NSColor grayColor] CGColor];
	} else {
		self.layer.borderWidth = 0;
	}
}

-(BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	[self highlightBorders:NO];
	
	// Check if the file is an acceptable image
	return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	if ([sender draggingSource] != self ) {
		NSImage *image = [[NSImage alloc] initWithPasteboard: [sender draggingPasteboard]];
		
		CGFloat size = image.size.width < image.size.height? image.size.width:image.size.height;
		image = [image cropAndResizeImage:CGSizeMake(size, size)];
		
		// Use layer in order to support Aspect-Fill behavior
		self.layer.contents = image;
		
		if ([self.delegate respondsToSelector:@selector(receivedFile:image:)]) {
			[self.delegate receivedFile:[[NSURL URLFromPasteboard: [sender draggingPasteboard]] path] image:image];
		}
	}
	
	return YES;
}

@end

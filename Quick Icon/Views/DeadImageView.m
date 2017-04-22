//
//  DeadImageView.m
//  Quick Icon
//
//  Created by Tawa Nicolas on 16/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "DeadImageView.h"

@implementation DeadImageView

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		// Stops the overlay ImageView from blocking the dragged image from reaching the TargetImageView below it.
		[self unregisterDraggedTypes];
	}
	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	// Add 1 point border
	self.layer.borderWidth = 1;
	self.layer.borderColor = [[NSColor grayColor] CGColor];
}

@end

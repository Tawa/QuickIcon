//
//  TargetImageView.h
//  Quick Icon
//
//  Created by Tawa Nicolas on 16/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol TargetImageViewDelegate <NSObject>

-(void)receivedFile:(NSString *)filePath image:(NSImage *)image;

@end

@interface TargetImageView : NSImageView <NSDraggingDestination>

@property (weak, nonatomic) IBOutlet id<TargetImageViewDelegate> delegate;

-(id)initWithCoder:(NSCoder *)coder;

@end

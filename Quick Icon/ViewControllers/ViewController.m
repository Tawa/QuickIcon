//
//  ViewController.m
//  Quick Icon
//
//  Created by Tawa Nicolas on 16/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "ViewController.h"
#import "TargetImageView.h"
#import "NSImage+CropAndResizeImage.h"

@interface ViewController() <TargetImageViewDelegate>
{
	// Variable used for the max progress indicator count;
	NSInteger currentCount;
	NSInteger totalCount;
}

@property (strong, nonatomic) NSString *directory;
@property (strong, nonatomic) NSString *filename;

@property (strong, nonatomic) NSImage *largeImage;

@end

@implementation ViewController

-(void)receivedFile:(NSString *)filePath image:(NSImage *)image
{
	// Hide the overlay label
	[self.label setHidden:YES];
	
	// Save the filename for use later when creating the results folder
	self.filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
	
	// The image will be saved for later
	self.largeImage = image;
	
	// Set the title of the window to the file name
	[[[NSApplication sharedApplication].windows firstObject] setTitle:[filePath lastPathComponent]];
}

-(NSData *)readJSONData:(NSString *)fileName
{
	NSURL *filePath = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"json"];
	NSString *jsonString = [[NSString alloc] initWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
	return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSDictionary *)readJSON:(NSData *)data
{
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

-(void)buildFolder:(NSString *)path
{
	NSError *error = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}

-(void)saveImage:(NSImage *)image atPath:(NSString *)path {
//	NSData *imageData = [[self fixSize:image] TIFFRepresentation];
	NSData *imageData = [image TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
	imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
	BOOL wrote = [[NSFileManager defaultManager] createFileAtPath:path contents:imageData attributes:nil];
	if (!wrote) {
		NSLog(@"FAILED at %@", path);
	}
}

/*
 *	This method generates the resized images from the json file name.
 */
-(void)generate:(NSString *)jsonName
{
	NSString *path = [self.directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/AppIcon.appiconset", jsonName]];
	[self buildFolder:path];
	
	NSData *jsonData = [self readJSONData:jsonName];
	NSDictionary *json = [self readJSON:jsonData];
	
	[[NSFileManager defaultManager] createFileAtPath:[path stringByAppendingPathComponent:@"Contents.json"] contents:jsonData attributes:nil];
	
	for (NSDictionary *icon in json[@"images"]) {
		NSString *fileName = icon[@"filename"];
		NSString *sizeString = icon[@"size"];
		NSString *scaleString = icon[@"scale"];
		
		// Scan for output image size
		NSScanner *scanner = [NSScanner scannerWithString:sizeString];
		CGFloat width,height;
		[scanner scanDouble:&width];
		[scanner scanString:@"x" intoString:nil];
		[scanner scanDouble:&height];
		
		// Get scale
		CGFloat scale = [scaleString floatValue];
		
		NSSize size = NSMakeSize(width*scale, height*scale);
		
		// Get output image, path, and save it.
		NSImage *image = [self.largeImage cropAndResizeImage:size];
		NSString *imagePath = [path stringByAppendingPathComponent:fileName];
		[self saveImage:image atPath:imagePath];
		[self increaseProgress];
	}
}

/*
 *	This method generates the iTunes Files.
 */
-(void)generateiTunes
{
	NSImage *image = [self.largeImage cropAndResizeImage:NSMakeSize(512, 512)];
	NSString *path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@1x.png"];
	[self saveImage:image atPath:path];
	[self increaseProgress];
	
	image = [self.largeImage cropAndResizeImage:NSMakeSize(1024, 1024)];
	path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@2x.png"];
	[self saveImage:image atPath:path];
	[self increaseProgress];

	image = [self.largeImage cropAndResizeImage:NSMakeSize(1536, 1536)];
	path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@3x.png"];
	[self saveImage:image atPath:path];
	[self increaseProgress];
}

/*
 *	This method is called at the end of generating files.
 */
-(void)finish{
	[self generateiTunes];
	
	// Open the output folder for the user
	[[NSWorkspace sharedWorkspace] openFile:self.directory];
	
	[self hideProgress];
}

/*
 *	Show progress and hide buttons
 */
-(void)showProgress
{
	[self.progressIndicator setMinValue:0];
	[self.progressIndicator setDoubleValue:0];
	[self.progressIndicator startAnimation:self];
	[self.progressIndicator setHidden:NO];
	currentCount = 0;
	[self.buttons setHidden:YES];
}

/*
 *	Increase the progress
 */
-(void)increaseProgress
{
	currentCount++;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.progressIndicator setDoubleValue:(double)currentCount];
	});
}

/*
 *	Hide progress and show buttons
 */
-(void)hideProgress
{
	[self.progressIndicator stopAnimation:self];
	[self.progressIndicator setHidden:YES];

	[self.buttons setHidden:NO];
}

-(void)start:(void(^)())completion
{
	if (self.filename == nil) {
		return;
	}
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanCreateDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setDirectoryURL:[NSURL URLWithString:self.directory]];
	[panel beginSheetModalForWindow:[NSApplication sharedApplication].windows[0] completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			self.directory = [[panel.URL path] stringByAppendingPathComponent:self.filename];
			[self showProgress];
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
				
				completion(self);
				dispatch_async(dispatch_get_main_queue(), ^{
					[self finish];
				});
			});
		}
	}];
}

-(IBAction)generateiOS:(id)sender {
	[self start:^{
		totalCount = 31;
		[self generate:@"iOS"];
	}];
}
-(IBAction)generatewatchOS:(id)sender {
	[self start:^{
		totalCount = 11;
		[self generate:@"watchOS"];
	}];
}
-(IBAction)generateiMessage:(id)sender
{
	[self start:^{
		totalCount = 12;
		[self generate:@"iMessage"];
	}];
}
-(IBAction)generatemacOS:(id)sender {
	[self start:^{
		totalCount = 13;
		[self generate:@"macOS"];
	}];
}

-(IBAction)generateAll:(id)sender {
	[self start:^{
		totalCount = 58;
		[self generate:@"iOS"];
		[self generate:@"watchOS"];
		[self generate:@"iMessage"];
		[self generate:@"macOS"];
	}];
}


@end

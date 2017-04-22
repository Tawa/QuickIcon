//
//  ViewController.m
//  Quick Icon
//
//  Created by Tawa Nicolas on 16/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "ViewController.h"

#import "TargetImageView.h"

@interface ViewController() <TargetImageViewDelegate>

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

-(NSImage *)fixSize:(NSImage *)sourceImage
{
	NSSize newSize = sourceImage.size;
	if (!sourceImage.isValid)
		return nil;
	
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
	[sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
	[newImage addRepresentation:rep];
	return newImage;
}

-(NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
	NSImage *sourceImage = [anImage copy];
	CGFloat s = 1;
	if (anImage.size.width <= anImage.size.height) {
		s = newSize.width / anImage.size.width;
	} else {
		s = newSize.height / anImage.size.height;
	}
	NSSize size = NSMakeSize(anImage.size.width * s, anImage.size.height * s);
	
	// The variables needed for cropping
	CGFloat x = 0;				// X Position shift
	CGFloat y = 0;				// Y Position shift
	CGFloat w = size.width;		// Result Width
	CGFloat h = size.height;	// Result Height
	CGFloat a = w/h;			// Aspect Ratio
	if (a > 1) {
		x = (h-w)*0.5;
	} else {
		y = (w-h)*0.5;
	}

	if (![sourceImage isValid]){
		NSLog(@"Invalid Image");
	} else {
		NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
		[newImage lockFocus];
		[sourceImage setSize:size];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[sourceImage drawAtPoint:NSMakePoint(x, y) fromRect:NSMakeRect(0, 0, w, h) operation:NSCompositingOperationCopy fraction:1.0];
		[newImage unlockFocus];
		return newImage;
	}
	return nil;
}

-(void)saveImage:(NSImage *)image atPath:(NSString *)path {
	NSData *imageData = [[self fixSize:image] TIFFRepresentation];
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
		NSImage *image = [self imageResize:self.largeImage newSize:size];
		NSString *imagePath = [path stringByAppendingPathComponent:fileName];
		[self saveImage:image atPath:imagePath];
	}
}

/*
 *	This method generates the iTunes Files.
 */
-(void)generateiTunes
{
	NSImage *image = [self imageResize:self.largeImage newSize:NSMakeSize(1536, 1536)];
	NSString *path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@3x.png"];
	[self saveImage:image atPath:path];
	
	image = [self imageResize:self.largeImage newSize:NSMakeSize(1024, 1024)];
	path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@2x.png"];
	[self saveImage:image atPath:path];
	
	image = [self imageResize:self.largeImage newSize:NSMakeSize(512, 512)];
	path = [self.directory stringByAppendingPathComponent:@"iTunesArtWork@1x.png"];
	[self saveImage:image atPath:path];
}

/*
 *	This method is called at the end of generating files.
 */
-(void)finish{
	[self generateiTunes];
	
	// Open the output folder for the user
	[[NSWorkspace sharedWorkspace] openFile:self.directory];
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
		[self generate:@"iOS"];
	}];
}
-(IBAction)generatewatchOS:(id)sender {
	[self start:^{
		[self generate:@"watchOS"];
	}];
}
-(IBAction)generatemacOS:(id)sender {
	[self start:^{
		[self generate:@"macOS"];
	}];
}
-(IBAction)generateiMessage:(id)sender
{
	[self start:^{
		[self generate:@"iMessage"];
	}];
}
-(IBAction)generateAll:(id)sender {
	[self start:^{
		[self generate:@"iOS"];
		[self generate:@"watchOS"];
		[self generate:@"iMessage"];
		[self generate:@"macOS"];
	}];
}


@end

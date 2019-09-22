//
//  NSImage+Extensions.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

extension NSImage {
	func cropAndResize(newSize: CGSize) -> NSImage? {
		guard isValid else { return nil }
		
		// Calculate the scale that should be used to calculate result
		let newAspectRatio = newSize.width / newSize.height
		let aspectRatio = size.width / size.height
		
		let s = newAspectRatio > aspectRatio ? size.width / newSize.width : size.height / newSize.height
		
		// Center of the target size
		let c = CGPoint(x: newSize.width * 0.5, y: newSize.height * 0.5)

		var x: CGFloat = 0				// X Position shift
		var y: CGFloat = 0				// Y Position shift
		let w: CGFloat = c.x * s * 2	// Result Width
		let h: CGFloat = c.y * s * 2	// Result Height
		
		if w > h {
			x = (h - w) * 0.5
		} else {
			y = (w - h) * 0.5
		}
		
		let rect = NSRect(x: x, y: y, width: w, height: h)
		
		guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
								   pixelsWide: Int(newSize.width),
								   pixelsHigh: Int(newSize.height),
								   bitsPerSample: 8,
								   samplesPerPixel: 4,
								   hasAlpha: true,
								   isPlanar: false,
								   colorSpaceName: .calibratedRGB,
								   bytesPerRow: 0,
								   bitsPerPixel: 0)
			else { return nil }
		rep.size = newSize
		
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
		draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height),
			 from: rect,
			 operation: .copy,
			 fraction: 1.0)
		NSGraphicsContext.restoreGraphicsState()
		
		let newImage = NSImage(size: newSize)
		newImage.addRepresentation(rep)
		return newImage
	}
}

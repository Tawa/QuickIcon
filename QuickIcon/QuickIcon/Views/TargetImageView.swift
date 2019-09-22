//
//  TargetImageView.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

protocol TargetImageViewDelegate: class {
	func received(file filePath: URL, image: NSImage)
}

class TargetImageView: NSImageView {
	
	weak var delegate: TargetImageViewDelegate?
	private var hasBorders: Bool = false {
		didSet {
			layer?.borderWidth = hasBorders ? 5 : 0
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		let layer = CALayer()
		layer.contentsGravity = .resizeAspectFill
		layer.masksToBounds = true
		layer.borderColor = NSColor.gray.cgColor
		layer.borderWidth = 0
		self.layer = layer
		self.wantsLayer = true
		
		registerForDraggedTypes(NSImage.imageTypes.map { NSPasteboard.PasteboardType($0) })
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		if NSImage.canInit(with: sender.draggingPasteboard),
			sender.draggingSourceOperationMask.contains(.copy) {
			hasBorders = true
			
			return .copy
		}
		
		return []
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		hasBorders = false
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		hasBorders = false
		
		return NSImage.canInit(with: sender.draggingPasteboard)
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		guard !(sender.draggingSource is TargetImageView) else { return false }
		
		guard let image = NSImage(pasteboard: sender.draggingPasteboard) else {
			return false
		}
		
		let size = min(image.size.width, image.size.height)
		let resizedImg = image.cropAndResize(newSize: CGSize(width: size, height: size))
		
		guard let resizedImage = resizedImg else {
			return false
		}
		
		self.layer?.contents = resizedImage
		
		if let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self],
														   options: nil) as? [URL],
			let firstUrl = urls.first {
			delegate?.received(file: firstUrl, image: image)
		}
		
		return true
	}
}

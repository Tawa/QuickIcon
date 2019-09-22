//
//  TargetImageView.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

protocol TargetImageViewDelegate: class {
	func received(file filePath: String, image: NSImage)
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
	}
}

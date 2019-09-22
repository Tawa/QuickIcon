//
//  DeadImageView.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

class DeadImageView: NSImageView {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		unregisterDraggedTypes()
		
		self.layer?.borderWidth = 1
		self.layer?.borderColor = NSColor.gray.cgColor
		self.image = NSImage(named: "gridoverlay")
	}
}

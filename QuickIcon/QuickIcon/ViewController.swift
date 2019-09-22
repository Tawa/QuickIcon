//
//  ViewController.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet private weak var label: NSTextField!
	@IBOutlet private weak var progressIndicator: NSProgressIndicator!
	@IBOutlet private weak var buttons: NSStackView!
	
	private var image: NSImage? = nil
	private var filePath: URL? = nil
	
	private func generate(iconTypes: [AppIcon.Preset]) {
		guard let image = image else { return }
		guard let filePath = filePath else { return }
		
		let icons = iconTypes.compactMap { AppIcon.load(preset: $0) }
		
		let totalImages: Int = icons.reduce(0) { $0 + $1.images.count }
		
		progressIndicator.minValue = 0
		progressIndicator.maxValue = Double(totalImages)
		
		for i in 0..<icons.count {
			let icon = icons[i]
			
			let generator = AppIconGenerator(appIcon: icon,
											 image: image,
											 filePath: filePath)
			generator.start {
				DispatchQueue.main.async {
					self.progressIndicator.increment(by: 1)
				}
			}
		}
	}
	
	@IBAction private func generateiOS(_ sender: NSButton) {
		generate(iconTypes: [.iOS])
	}
}

extension ViewController: TargetImageViewDelegate {
	func received(file filePath: URL, image: NSImage) {
		label.isHidden = true
		
		self.filePath = filePath
		self.image = image
	}
}

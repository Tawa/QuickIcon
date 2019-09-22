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
	@IBOutlet private weak var progressIndicator: NSProgressIndicator! {
		didSet {
			progressIndicator.minValue = 0
			progressIndicator.maxValue = 20
			progressIndicator.isDisplayedWhenStopped = false
			progressIndicator.isHidden = true
		}
	}
	@IBOutlet private weak var iOSButton: NSButton!
	@IBOutlet private weak var macOSButton: NSButton!
	@IBOutlet private weak var iMessageButton: NSButton!
	@IBOutlet private weak var watchOSButton: NSButton!
	@IBOutlet private weak var iTunesButton: NSButton!

	private var image: NSImage? = nil
	private var filePath: URL? = nil
	
	private func generate(iconTypes: [AppIcon.Preset]) {
		guard let image = image else { return }
		guard let filePath = filePath else { return }
		
		let iconsDetails: [AppIconDetails] = iconTypes.compactMap {
			guard let icon = AppIcon.load(preset: $0) else { return nil }
			return AppIconDetails(appIcon: icon,
								  folderName: $0.fileName)
		}
		
		let totalImages: Int = iconsDetails.reduce(0) { $0 + $1.appIcon.images.count }
		
		progressIndicator.minValue = 0
		progressIndicator.maxValue = Double(totalImages)
		progressIndicator.doubleValue = 0
		
		for i in 0..<iconsDetails.count {
			let icon = iconsDetails[i]
			
			let generator = AppIconGenerator(appIcon: icon.appIcon,
											 image: image,
											 filePath: filePath,
											 folderName: icon.folderName)
			
			progressIndicator.isHidden = false
			generator.start(updateProgress: {
				self.progressIndicator.increment(by: 1)
			}) { completed in
				if completed {
					self.showAlert(message: "Done")
				}
				self.progressIndicator.isHidden = true
			}
		}
	}
	
	@IBAction private func generate(_ sender: NSButton) {
		guard image != nil else {
			showNoImageAlert()
			return
		}
		
		var iconTypes = [AppIcon.Preset]()
		
		if iOSButton.state == .on {
			iconTypes.append(.iOS)
		}
		
		guard !iconTypes.isEmpty else {
			showNoSelectionsAlert()
			
			return
		}
		generate(iconTypes: iconTypes)
	}
	
	private func showAlert(message: String) {
		let alert = NSAlert()
		alert.messageText = message
		alert.addButton(withTitle: "Ok")
		alert.runModal()
	}
	
	private func showNoSelectionsAlert() {
		showAlert(message: "No selections!\nPlease select which files you want to generate first.")
	}
	
	private func showNoImageAlert() {
		showAlert(message: "Image missing!\nPlease add an image file.")
	}
}

extension ViewController: TargetImageViewDelegate {
	func received(file filePath: URL, image: NSImage) {
		label.isHidden = true
		
		self.filePath = filePath
		self.image = image
	}
}

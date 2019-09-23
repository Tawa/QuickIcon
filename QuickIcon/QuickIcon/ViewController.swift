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
	@IBOutlet private weak var iTunesButton: NSButton!

	private var image: NSImage? = nil
	private var filePath: URL? = nil
	
	private func generate(iconTypes: [AppIcon.Preset], in directory: String) {
		guard let image = image else { return }
		
		let iconsDetails: [AppIconDetails] = iconTypes.compactMap {
			guard let icon = AppIcon.load(preset: $0) else { return nil }
			return AppIconDetails(appIcon: icon,
								  folderName: $0.fileName)
		}
		
		let totalImages: Int = iconsDetails.reduce(0) { $0 + $1.appIcon.images.count }
		
		progressIndicator.minValue = 0
		progressIndicator.maxValue = Double(totalImages)
		progressIndicator.doubleValue = 0
		
		progressIndicator.isHidden = false
		for i in 0..<iconsDetails.count {
			let icon = iconsDetails[i]
			
			print("Generating for: \(i)")
			let generator = AppIconGenerator(appIcon: icon.appIcon,
											 image: image,
											 folderName: icon.folderName)
			
			generator.start(in: directory, updateProgress: {
				self.progressIndicator.increment(by: 1)
			}) { completed in
				print("Done: \(completed) : \(i)")
				if i == iconsDetails.count - 1 {
					if completed {
						self.showAlert(message: "Done")
					}
					self.progressIndicator.isHidden = true
				}
			}
		}
	}
	
	@IBAction private func generate(_ sender: NSButton) {
		guard let filePath = filePath else { return }
		guard image != nil else {
			showNoImageAlert()
			return
		}
		
		var iconTypes = [AppIcon.Preset]()
		
		if iOSButton.state == .on {
			iconTypes.append(.iOS)
		}
		
		if macOSButton.state == .on {
			iconTypes.append(.macOS)
		}
		
		if iTunesButton.state == .on {
			iconTypes.append(.iTunes)
		}
		
		guard !iconTypes.isEmpty else {
			showNoSelectionsAlert()
			
			return
		}
		
		FolderSelector(filePath: filePath).getFolder { (directory) in
			self.generate(iconTypes: iconTypes, in: directory)
		}
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

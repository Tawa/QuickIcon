//
//  AppIconGenerator.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

class AppIconGenerator {
	
	private let appIcon: AppIcon
	private let image: NSImage
	private let filePath: URL
	private let folderName: String
	
	private var fileName: String {
		return filePath.deletingPathExtension().lastPathComponent
	}
	
	private var updateProgress: (() -> Void)?
	private var completion: ((Bool) -> Void)?
	
	init(appIcon: AppIcon,
		 image: NSImage,
		 filePath: URL,
		 folderName: String) {
		self.appIcon = appIcon
		self.image = image
		self.filePath = filePath
		self.folderName = folderName
	}
	
	func start(updateProgress: @escaping () -> Void, _ completion: @escaping (Bool) -> Void) {
		self.updateProgress = updateProgress
		self.completion = completion
		
		let panel = NSOpenPanel()
		panel.canCreateDirectories = true
		panel.canChooseFiles = false
		panel.canChooseDirectories = true
		panel.directoryURL = filePath.deletingLastPathComponent()
		panel.beginSheetModal(for: NSApplication.shared.windows[0]) { (result) in
			switch result {
			case .OK:
				guard let directory = panel.url?.path.appending("/\(self.fileName)") else {
					self.finish()
					return
				}
				DispatchQueue.global(qos: .background).async {
					self.generate(in: directory)
				}
			default:
				completion(false)
				break
			}
		}
	}
	
	private func finish() {
		DispatchQueue.main.async {
			self.completion?(true)
		}
	}
	
	private func buildFolder(path: String) {
		do {
			try FileManager.default.createDirectory(atPath: path,
													withIntermediateDirectories: true,
													attributes: nil)
		} catch {
			print("COULD NOT CREATE DIRECTORY: \(error.localizedDescription)")
		}
	}
	
	private func saveContentsFile(path: String) {
		appIcon.save(to: path.appending("/Contents.json"))
	}
	
	private func generate(in directory: String) {
		let path = directory.appending("/\(folderName)/AppIcon.appiconset")
		
		buildFolder(path: path)
		saveContentsFile(path: path)
		
		for image in appIcon.images {
			let imagePath = path.appending("/\(image.filename)")
			guard let resizedImage = self.image.cropAndResize(newSize: image.actualSize)
				else {
					continue
			}
			
			resizedImage.save(at: imagePath)
			DispatchQueue.main.async {
				self.updateProgress?()
			}
		}
		
		DispatchQueue.main.async {
			self.completion?(true)
		}
	}
}

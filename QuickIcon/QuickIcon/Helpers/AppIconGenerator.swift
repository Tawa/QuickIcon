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
	private let folderName: String
	
	private var updateProgress: (() -> Void)?
	private var completion: ((Bool) -> Void)?
	
	init(appIcon: AppIcon,
		 image: NSImage,
		 folderName: String) {
		self.appIcon = appIcon
		self.image = image
		self.folderName = folderName
	}
	
	func start(in directory: String, updateProgress: @escaping () -> Void, _ completion: @escaping (Bool) -> Void) {
		self.updateProgress = updateProgress
		self.completion = completion
		
		self.generate(in: directory)
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

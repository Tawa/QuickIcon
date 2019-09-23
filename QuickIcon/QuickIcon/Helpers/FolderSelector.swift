//
//  FolderSelector.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 23.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

class FolderSelector {
	
	private let filePath: URL
	private var fileName: String {
		return filePath.deletingPathExtension().lastPathComponent
	}
	
	init(filePath: URL) {
		self.filePath = filePath
	}
	
	func getFolder(_ completion: @escaping (String) -> Void) {
		let panel = NSOpenPanel()
		panel.canCreateDirectories = true
		panel.canChooseFiles = false
		panel.canChooseDirectories = true
		panel.directoryURL = filePath.deletingLastPathComponent()
		panel.beginSheetModal(for: NSApplication.shared.windows[0]) { (result) in
			switch result {
			case .OK:
				guard let directory = panel.url?.path.appending("/\(self.fileName)") else {
					return
				}
				completion(directory)
			default:
				break
			}
		}
	}
}

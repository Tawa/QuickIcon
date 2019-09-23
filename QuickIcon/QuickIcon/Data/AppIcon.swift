//
//  AppIcon.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Foundation

struct AppIcon: Codable {
	let images: [Image]
	let info: Info = Info()
	
	enum Preset: String {
		case iOS
		case macOS
		case iTunes
		
		var fileName: String {
			return self.rawValue
		}
	}
	
	static func load(from fileName: String) -> AppIcon? {
		guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "json")
			else {
				return nil
		}
		
		do {
			let data = try Data(contentsOf: filePath)
			
			let jsonDecoder = JSONDecoder()
			return try jsonDecoder.decode(AppIcon.self, from: data)
		} catch {
			print("Error Loading JSONFile: \(error.localizedDescription)")
			return nil
		}
	}
	
	static func load(preset: Preset) -> AppIcon? {
		return load(from: preset.fileName)
	}
	
	func save(to filePath: String) {
		let jsonEncoder = JSONEncoder()
		do {
			let data = try jsonEncoder.encode(self)
			try data.write(to: URL(fileURLWithPath: filePath))
		} catch {
			print("Could not write Contents.json: \(error.localizedDescription)")
		}
	}
}

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
	let info: Info
	
	enum Default {
		case iOS
		
		var fileName: String {
			switch self {
			case .iOS:
				return "iOS"
			}
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
	
	static func load(_ defaultFile: Default) -> AppIcon? {
		return load(from: defaultFile.fileName)
	}
}

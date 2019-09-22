//
//  Image.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Foundation

struct Image: Codable {
	private let idiom: String
	private let size: String
	private let scale: String
	let filename: String
	
	enum CodingKeys: String, CodingKey {
		case idiom
		case size
		case filename
		case scale
	}
		
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		idiom = try container.decode(String.self, forKey: .idiom)
		size = try container.decode(String.self, forKey: .size)
		scale = try container.decode(String.self, forKey: .scale)
		
		let defaultFileName = "\(idiom)-Icon-\(size)@\(scale).png"
		let readFileName = try? container.decode(String.self, forKey: .filename)
		filename = readFileName ?? defaultFileName
	}
	
	lazy var actualScale: Int = {
		guard let scaleString = scale.components(separatedBy: "x").first,
			let scaleInt = Int(scaleString)
		else {
			return 1
		}
		
		return scaleInt
	}()
	
	lazy var actualSize: CGSize = {
		let sizeComponents = self.size.components(separatedBy: "x")
		guard sizeComponents.count == 2,
			let width = Double(sizeComponents[0]),
			let height = Double(sizeComponents[1])
		else {
			return CGSize(width: 1, height: 1)
		}
		
		return CGSize(width: CGFloat(width) * CGFloat(actualScale),
					  height: CGFloat(height) * CGFloat(actualScale))
	}()
}

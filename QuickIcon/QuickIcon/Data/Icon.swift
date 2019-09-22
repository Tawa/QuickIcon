//
//  Icon.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Foundation

struct Icon: Decodable {
	let idiom: String
	let size: String
	let filename: String
	let scale: String
	
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

//
//  NSImageExtensionsTests.swift
//  QuickIconTests
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import XCTest
@testable import QuickIcon

class NSImageExtensionsTests: XCTestCase {
	
	let bundle = Bundle(for: NSImageExtensionsTests.self)

    func testCropAndResize() {
		let img = bundle.image(forResource: "Icon")
		
		guard let image = img else {
			XCTFail("Failed to load image")
			return
		}
		
		let newImg = image.cropAndResize(newSize: CGSize(width: 100,
														 height: 100))
		
		guard let newImage = newImg else {
			XCTFail("Failed to resize image")
			return
		}
		
		XCTAssertEqual(newImage.size.width, 100)
		XCTAssertEqual(newImage.size.height, 100)
    }
}

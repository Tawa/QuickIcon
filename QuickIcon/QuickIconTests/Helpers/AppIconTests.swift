//
//  AppIconTests.swift
//  QuickIconTests
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import XCTest
@testable import QuickIcon

class AppIconTests: XCTestCase {

	func testiOSJSONFile() {
		let appIcon = AppIcon.load(preset: .iOS)
		
		XCTAssertNotNil(appIcon)
		XCTAssertEqual(appIcon?.images.count, 18)
		
		let first = appIcon!.images[0]
		XCTAssertEqual(first.actualScale, 2)
		XCTAssertEqual(first.actualSize, CGSize(width: 40, height: 40))
		
		let iPadIcon = appIcon!.images[16]
		XCTAssertEqual(iPadIcon.actualScale, 2)
		XCTAssertEqual(iPadIcon.actualSize, CGSize(width: 167, height: 167))
	}

	func testmacOSJSONFile() {
		let appIcon = AppIcon.load(preset: .macOS)
		
		XCTAssertNotNil(appIcon)
		XCTAssertEqual(appIcon?.images.count, 10)
		
		let first = appIcon!.images[0]
		XCTAssertEqual(first.actualScale, 1)
		XCTAssertEqual(first.actualSize, CGSize(width: 16, height: 16))
		
		let iPadIcon = appIcon!.images[9]
		XCTAssertEqual(iPadIcon.actualScale, 2)
		XCTAssertEqual(iPadIcon.actualSize, CGSize(width: 1024, height: 1024))
	}

	func testNoFile() {
		let appIcon = AppIcon.load(from: "randomfilename")
		
		XCTAssertNil(appIcon)
	}

}

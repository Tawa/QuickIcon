//
//  JSONLoaderTests.swift
//  QuickIconTests
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import XCTest
@testable import QuickIcon

class JSONLoaderTests: XCTestCase {

    func testiOSJsonFile() {
		let jsonLoader = JSONLoader()
		
		let appIcon = jsonLoader.load(fileName: "iOS")
		
		XCTAssertNotNil(appIcon)
		XCTAssertEqual(appIcon?.images.count, 18)
		
		var first = appIcon!.images[0]
		XCTAssertEqual(first.actualScale, 2)
		XCTAssertEqual(first.actualSize, CGSize(width: 40, height: 40))
		
		var iPadIcon = appIcon!.images[16]
		XCTAssertEqual(iPadIcon.actualScale, 2)
		XCTAssertEqual(iPadIcon.actualSize, CGSize(width: 167, height: 167))
    }
}

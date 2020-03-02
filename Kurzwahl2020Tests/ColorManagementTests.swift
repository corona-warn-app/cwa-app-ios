//
//  ColorManagementTests.swift
//  Kurzwahl2020Tests
//
//  Created by Vogel, Andreas on 02.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Kurzwahl2020

class ColorManagementTests: XCTestCase {
    
    var sut: ColorManagement = ColorManagement()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetThumbnail() {
        XCTAssertTrue(sut.getThumbnailName(withIndex: 0).count > 0 )
        XCTAssertTrue(sut.getThumbnailName(withIndex: 1).count > 0 )
        XCTAssertTrue(sut.getThumbnailName(withIndex: 2).count > 0 )
        XCTAssertTrue(sut.getThumbnailName(withIndex: 3).count == 0 )
    }

}

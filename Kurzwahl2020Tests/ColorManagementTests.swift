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
        let index : Int = 0
        sut.getThumbnail(withIndex: index)
    }

}

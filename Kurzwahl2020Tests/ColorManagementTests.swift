//
//  ColorManagementTests.swift
//  Kurzwahl2020Tests
//
//  Created by Vogel, Andreas on 02.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Call_by_Color_36

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
        
    }
    
    func testGetAllThumbnails() {
        let result = sut.getAllPalettes()
        XCTAssertTrue(result.count == 9)
    }
    
    func testSetPalette() {
        sut.setScreenPalette(withIndex: 0, name: c_red)
        let result = sut.getScreenPaletteName(withIndex: 0)
        XCTAssertEqual(result, c_red)
        
        XCTAssertEqual(sut.getThumbnailName(withIndex: 0), c_tn_red_lm)
    }

    func testColorCodes() {
        for p in sut.getAllPalettes() {
            XCTAssertTrue(p.colors.count == 12)
        }
    }
    
    func testGetPalette() {
        for p in sut.getAllPalettes() {
            let p = sut.getPalette(withName: p.name)
            XCTAssertTrue(p.colors.count == 12)
        }
    }
    
}

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

    func test_getUIColor() {
        for index in 0..<sut.allColors.count {
            XCTAssertNotNil(sut.getUIColor(withId: index))
        }
        XCTAssertNotNil(sut.getUIColor(withId: (sut.allColors.count)))
    }
    
    func test_thumbnail_names_of_user_selected_palettes() {
        for index in 0...2 {
        XCTAssertTrue(sut.getThumbnailName(withIndex: index).count > 0 )
        }
    }
    
    func test_set_screen_palette() {
        sut.setScreenPalette(withIndex: 0, name: c_red)
        let result = sut.getScreenPaletteName(withIndex: 0)
        XCTAssertEqual(result, c_red)
        
        XCTAssertEqual(sut.getThumbnailName(withIndex: 0), c_tn_red_lm)
    }

    func test_modifyScreenPalette() {
        //GIVEN
        sut.modifyScreenPalette(withIndex: 0, name: c_palette01)
        sut.modifyScreenPalette(withIndex: 1, name: c_palette02)
        sut.modifyScreenPalette(withIndex: 2, name: c_palette03)
        XCTAssertEqual(sut.getScreenPaletteName(withIndex: 0), c_palette01)
        
        for screen in 0...2 {
            sut.modifyScreenPalette(withIndex: screen, name: c_blue)
            XCTAssertEqual(sut.getScreenPaletteName(withIndex: screen), c_blue)
            XCTAssertNotEqual(sut.getScreenPaletteName(withIndex: 0), c_palette01)
            XCTAssertNotEqual(sut.getScreenPaletteName(withIndex: 0), c_palette02)
            XCTAssertNotEqual(sut.getScreenPaletteName(withIndex: 0), c_palette03)
        }
    }
    
    func test_set_all_colors() {
        sut.setAllColors()
        XCTAssertEqual(sut.allColors.count, globalNoOfScreens * 12)
    }
    
    func test_get_colors() {
        let x = sut.getColors(forPalette: c_red)
        XCTAssertEqual(x.count, 12)
    }
    
    func test_color_codes_of_user_selected_palettes() {
        for p in sut.getAllPalettes() {
            XCTAssertTrue(p.colors.count == 12)
        }
        XCTAssertEqual(sut.getAllPalettes().count, c_number_of_available_palettes)
    }
    
    func test_number_of_available_palettes() {
        XCTAssertEqual(sut.getAllPalettes().count, c_number_of_available_palettes)
    }
    
    func test_get_palette() {
        for p in sut.getAllPalettes() {
            let p = sut.getPalette(withName: p.name)
            XCTAssertTrue(p.colors.count == 12)
        }
    }
    
}

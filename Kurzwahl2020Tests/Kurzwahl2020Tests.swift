//
//  Kurzwahl2020Tests.swift
//  Kurzwahl2020Tests
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import XCTest
import Foundation
import SwiftUI
@testable import Kurzwahl2020

class Kurzwahl2020Tests: XCTestCase {

    var sut : kurzwahlModel = kurzwahlModel()
       
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


//MARK: tiles class test
  
    func testTilesGetName() {
        let bob = tile.init(id: 0, name: "Bob", phoneNumber: "0621888", backgroundColor: "testColor")
        sut.modifyTile(withTile: bob)
        
        let charlie = tile.init(id: globalMaxTileNumber, name: "Charlie", phoneNumber: "0621777", backgroundColor: "testColor")
        sut.modifyTile(withTile: charlie)
        
        let testName1 = sut.getName(withId: bob.id)
        XCTAssertTrue(testName1 == bob.name)
        
        let testName2 = sut.getName(withId: charlie.id)
        XCTAssertTrue(testName2 == charlie.name)
      
    }

    func testTilesModifyTiles() {

        let bob = tile.init(id: 0, name: "Bob", phoneNumber: "0621888", backgroundColor: "testColor")
        sut.modifyTile(withTile: bob)
        
        let charlie = tile.init(id: globalMaxTileNumber, name: "Charlie", phoneNumber: "0621777", backgroundColor: "testColor")
        sut.modifyTile(withTile: charlie)
        
        var x = tile(id: 0, name: "x", phoneNumber: "x", backgroundColor: "x")
        do {
            x = try sut.getTile(withId: 0)
        } catch {
            XCTFail()
        }
        XCTAssertTrue(x.id == bob.id)
        XCTAssertTrue(x.name == bob.name)
        XCTAssertTrue(x.phoneNumber == bob.phoneNumber)
        
        
        do {
            x = try sut.getTile(withId: globalMaxTileNumber + 1)
            XCTFail()
        } catch {
        
        }
        
        do {
            x = try sut.getTile(withId: globalMaxTileNumber)
            XCTAssertTrue(x.id == charlie.id)
            XCTAssertTrue(x.name == charlie.name)
            XCTAssertTrue(x.phoneNumber == charlie.phoneNumber)
        } catch {
            XCTFail()
        }

        
    }
    
    
    func testTilesModifyTilesWithIllegalId() {
        
        let charlie = tile.init(id: 99, name: "Charlie", phoneNumber: "0621333333", backgroundColor: "ColorBlue")
        let dummy = tile(id: 0, name: "x", phoneNumber: "x", backgroundColor: "x")
        sut.modifyTile(withTile: charlie)


        var x = dummy
        do {
            x = try sut.getTile(withId: charlie.id)
        } catch {
        }
        
        XCTAssertTrue(x.id == dummy.id)
        XCTAssertTrue(x.name == dummy.name)
        XCTAssertTrue(x.phoneNumber == dummy.phoneNumber)
        XCTAssertTrue(x.backgroundColor == dummy.backgroundColor)
    }
    
    
    func testModelGetFontsize() {
        var size:Int = 0
        size = sut.getFontSizeAsInt()
        
        let property = Int(sut.fontSize)
        XCTAssertTrue(size == property)
    }
    
    
    func testGetColorName() {
        let bob = tile.init(id: 0, name: "Bob", phoneNumber: "0621888", backgroundColor: "OrangeFF9500")
        sut.modifyTile(withTile: bob)
        
        let aColor = sut.getColorName(withId: 0)
        XCTAssertEqual(bob.backgroundColor, aColor)
    }
    
    
    func testGetColor() {
        let colorName : String = "OrangeFF9500"
        let bob = tile.init(id: 0, name: "Bob", phoneNumber: "0621888", backgroundColor: colorName)
        sut.modifyTile(withTile: bob)
        
        let aColor = sut.getColor(withId: 0)
        let testColor : Color = Color.init(colorName, bundle: nil)
        XCTAssertEqual(testColor, aColor)
    }

    
//    func testGetUIColor() {
//        let colorName : String = "OrangeFF9500"
//        let bob = tile.init(id: 0, name: "Bob", phoneNumber: "0621888", backgroundColor: colorName)
//        sut.modifyTile(withTile: bob)
//        
//        let aColor : UIColor = sut.getUIColor(withId: 0)
//        let testColor : Color = Color.init(colorName, bundle: nil)
//        let myColor = Color(aColor)
//        XCTAssertEqual(testColor, Color(aColor))
//    }
    
    
    func testPersist() {
//        var names : [String] =
//        ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrott",
//         "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima",
//         "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
//         "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
//         "Yankee", "Zulu"]
        
        sut.persist()
    }
    

}

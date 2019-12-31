//
//  Kurzwahl2020Tests.swift
//  Kurzwahl2020Tests
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Kurzwahl2020

class Kurzwahl2020Tests: XCTestCase {

    var sut : kurzwahlModel = kurzwahlModel()
       
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
//MARK: tiles class test
    func testTilesGetTiles() {
        
        let bravo = tile.init(id: 1, name: "Bravo", phoneNumber: "062111223344")
        let lima = tile.init(id: 11, name: "Lima", phoneNumber: "062111223344")
       
        var testBravo: tile
        var testLima: tile
        
        do {
            testBravo = try sut.getTile(withId: 1)
            testLima = try sut.getTile(withId: 11)
        } catch {
            testBravo = tile(id: 0, name: "x", phoneNumber: "x")
            testLima = tile(id: 0, name: "x", phoneNumber: "x")
        }
        XCTAssertTrue(testBravo.id == bravo.id)
        XCTAssertTrue(testBravo.name == bravo.name)
        XCTAssertTrue(testBravo.phoneNumber == bravo.phoneNumber)

        XCTAssertTrue(testLima.id == lima.id)
        XCTAssertTrue(testLima.name == lima.name)
        XCTAssertTrue(testLima.phoneNumber == lima.phoneNumber)
    }

    
    func testTilesGetTilesBoundCheck() {
        let maxIndex = globalNumberOfRows * 2 * 2 - 1
        let maxIndexPlusOne = maxIndex + 1
        let Xray = tile.init(id: 23, name: "X-ray", phoneNumber: "062111223344")
       
        var testXray: tile
        var testNull: tile
        testNull = tile(id: 0, name: "0", phoneNumber: "0")
        
        do {
            testXray = try sut.getTile(withId: maxIndex)
        } catch {
            testXray = testNull
        }
        XCTAssertTrue(testXray.id == Xray.id)
        XCTAssertTrue(testXray.name == Xray.name)
        XCTAssertTrue(testXray.phoneNumber == Xray.phoneNumber)
        
        do {
            testXray = try sut.getTile(withId: maxIndexPlusOne)
        } catch {
            testXray = testNull
        }
        XCTAssertTrue(testXray.id == testNull.id)
        XCTAssertTrue(testXray.name == testNull.name)
        XCTAssertTrue(testXray.phoneNumber == testNull.phoneNumber)
        
    }
    
    
    func testTilesGetName() {
        
        let bravo = tile.init(id: 1, name: "Bravo", phoneNumber: "062111223344")
        let lima = tile.init(id: 42, name: "Lima", phoneNumber: "062111223344")
       
        var testName: String
        
        testName = sut.getName(withId: bravo.id)
        XCTAssertTrue(testName == bravo.name)
        
        testName = sut.getName(withId: lima.id)
        XCTAssertFalse(testName == lima.name)
      
    }

    func testTilesModifyTiles() {

        let bob = tile.init(id: 1, name: "Bob", phoneNumber: "0621888")
        sut.modifyTile(withTile: bob)
        
//        let charlie = tile.init(id: 1, name: "Charlie", phoneNumber: "0621777")
//        sut.modifyTile(withTile: charlie)
        
        var x = tile(id: 0, name: "x", phoneNumber: "x")
        do {
            x = try sut.getTile(withId: 1)
        } catch {
        
        }
        XCTAssertTrue(x.id == bob.id)
        XCTAssertTrue(x.name == bob.name)
        XCTAssertTrue(x.phoneNumber == bob.phoneNumber)
    }
    
    
    func testTilesModifyTilesWithIllegalId() {
        
        let charlie = tile.init(id: 42, name: "Charlie", phoneNumber: "0621333333")
        let dummy = tile(id: 0, name: "x", phoneNumber: "x")
        sut.modifyTile(withTile: charlie)


        var x = dummy
        do {
            x = try sut.getTile(withId: charlie.id)
        } catch {
        }
        
        XCTAssertTrue(x.id == dummy.id)
        XCTAssertTrue(x.name == dummy.name)
        XCTAssertTrue(x.phoneNumber == dummy.phoneNumber)

    }
    
    
    func testModelGetFontsize() {
        var size:Int = 0
        size = sut.getFontSizeAsInt()
        
        let property = Int(sut.fontSize)
        XCTAssertTrue(size == property)
    }
    
}

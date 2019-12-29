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
    func testTilesaddTiles() {
        let alice = tile.init(id: 0, name: "Alice", phoneNumber: "0621999999")
        var sut : phoneBook
        sut = phoneBook(withTile: alice)
        
        XCTAssertNotNil(sut)
        let bob = tile.init(id: 1, name: "Bob", phoneNumber: "0621888")
        sut.addTile(withTile: bob)
        XCTAssertNotNil(bob)
        
        var x: tile
        var y: tile
        
        do {
            x = try sut.getTile(withId: 1)
            y = try sut.getTile(withId: 0)
        } catch {
            x = tile(id: 0, name: "x", phoneNumber: "x")
            y = tile(id: 0, name: "x", phoneNumber: "x")
        }
        XCTAssertTrue(x.id == bob.id)
        XCTAssertTrue(x.name == bob.name)
        XCTAssertTrue(x.phoneNumber == bob.phoneNumber)

        XCTAssertTrue(y.id == alice.id)
        XCTAssertTrue(y.name == alice.name)
        XCTAssertTrue(y.phoneNumber == alice.phoneNumber)
    }

    func testTilesModifyTiles() {
        let alice = tile.init(id: 0, name: "Alice", phoneNumber: "0621999999")
        var sut : phoneBook
        sut = phoneBook(withTile: alice)
        
        let bob = tile.init(id: 1, name: "Bob", phoneNumber: "0621888")
        sut.addTile(withTile: bob)
        XCTAssertNotNil(bob)
        
        let charlie = tile.init(id: 1, name: "Charlie", phoneNumber: "0621777")
        sut.modifyTile(withTile: charlie)
        
        var x = tile(id: 0, name: "x", phoneNumber: "x")
        do {
            x = try sut.getTile(withId: 1)
        } catch {
        
        }
        XCTAssertTrue(x.id == charlie.id)
        XCTAssertTrue(x.name == charlie.name)
        XCTAssertTrue(x.phoneNumber == charlie.phoneNumber)
    }
    
    
    func testTilesModifyTilesWithIllegalId() {
        let alice = tile.init(id: 0, name: "Alice", phoneNumber: "0621000000")
        var sut : phoneBook
        sut = phoneBook(withTile: alice)
        
        let bob = tile.init(id: 2, name: "Bob", phoneNumber: "0621222222")
        sut.addTile(withTile: bob)
        
        let charlie = tile.init(id: 3, name: "Charlie", phoneNumber: "0621333333")
        sut.modifyTile(withTile: charlie)

        var x = tile(id: 0, name: "x", phoneNumber: "x")
        do {
            x = try sut.getTile(withId: 3)
        } catch {
        }
        
        XCTAssertTrue(x.id == charlie.id)
        XCTAssertTrue(x.name == charlie.name)
        XCTAssertTrue(x.phoneNumber == charlie.phoneNumber)

        let dennis = tile.init(id: 104, name: "Dennis", phoneNumber: "062144444444")
        sut.modifyTile(withTile: dennis)

        x = tile(id: 0, name: "x", phoneNumber: "x")
        do {
            x = try sut.getTile(withId: 1)
        } catch {
        }
        
        XCTAssertTrue(x.id == 0)
        XCTAssertTrue(x.name == "x")
        XCTAssertTrue(x.phoneNumber == "x")
        
        var z = tile(id: 0, name: "x", phoneNumber: "x")
        
        do {
            z = try sut.getTile(withId: 104)
        } catch {
        }
        
        XCTAssertTrue(z.id == 0)
        XCTAssertTrue(z.name == "x")
        XCTAssertTrue(z.phoneNumber == "x")
    }
    
}

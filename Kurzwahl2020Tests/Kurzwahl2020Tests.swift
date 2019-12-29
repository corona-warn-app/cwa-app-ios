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
//MARK: person class test
    func testPerson() {
        let alice = person.init(id: 1, name: "Alice", phoneNumber: "0621999999")
        XCTAssertNotNil(alice)
        let bob = person.init(id: 2, name: "Bob", phoneNumber: "0621888")
        XCTAssertNotNil(bob)
        
        XCTAssertTrue(alice.name == "Alice")
        XCTAssertTrue(bob.name == "Bob")
        XCTAssertTrue(bob.phoneNumber == "0621888")
        XCTAssertTrue(bob.id == 2)
    }
}

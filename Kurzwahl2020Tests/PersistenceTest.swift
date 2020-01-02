//
//  PersistenceTest.swift
//  Kurzwahl2020Tests
//
//  Created by Andreas Vogel on 01.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Kurzwahl2020

class PersistenceTests: XCTestCase {
    var sut : storage = storage()
    var testNames : [String] = ["abc", "def"]
    var testNumbers : [String] = ["012", "+49"]
    let namesTestfile : String = "namesTestfile"
    let numbersTestfile : String = "numbersTestfile"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPersistForNames() {
        var result : [String] = [""]
        sut.persist(withNames: testNames, withFilename: namesTestfile)
        do {
            result = try sut.loadNames(withFilename: namesTestfile)
        } catch {
            
        }
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result == testNames)
    }
    
    func testPersistForNumbers() {
        var result : [String] = [""]
        sut.persist(withNames: testNumbers, withFilename: numbersTestfile)
        do {
            result = try sut.loadNumbers(withFilename: numbersTestfile)
        } catch {
            
        }
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result == testNumbers)
    }

    
}

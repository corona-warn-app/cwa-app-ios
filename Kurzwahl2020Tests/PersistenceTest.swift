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
    var testSettings : [String : String] = ["alpha" : "beta", "charlie": "delta"]
    let namesTestfile : String = "namesTestfile"
    let numbersTestfile : String = "numbersTestfile"
    let settingsTestfile : String = "settingsTestfile"

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let directory : URL = FileManager.sharedContainerURL()
        let fullPathNames = directory.appendingPathComponent(namesTestfile)
        let fullPathNumbers = directory.appendingPathComponent(numbersTestfile)
        let fullPathSettings = directory.appendingPathComponent(settingsTestfile)
        do {
            try FileManager.default.removeItem(at: fullPathNames)
            try FileManager.default.removeItem(at: fullPathNumbers)
            try FileManager.default.removeItem(at: fullPathSettings)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }

    
    func testPersistForNames() {
        var result : [String] = [""]
        sut.persist(withNames: testNames, withFilename: namesTestfile)
        do {
            result = try sut.loadNames(withFilename: namesTestfile)
        } catch {
            
        }
        
        XCTAssertTrue(result == testNames)
    }
    
    
    func testPersistForNumbers() {
        var result : [String] = [""]
        sut.persist(withNames: testNumbers, withFilename: numbersTestfile)
        do {
            result = try sut.loadNumbers(withFilename: numbersTestfile)
        } catch {
            
        }
        
        XCTAssertTrue(result == testNumbers)
    }

    
    func testPersistForSettings() {
        var result : [String : String] = ["":""]
        sut.persist(settings: testSettings, withFilename: settingsTestfile)
        do {
            result = try sut.loadSettings(withFilename: settingsTestfile)
        } catch {
            
        }
        
        XCTAssertTrue(result == testSettings)
    }
    
    
}

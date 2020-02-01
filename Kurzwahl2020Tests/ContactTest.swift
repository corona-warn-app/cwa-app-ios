//
//  ContactTest.swift
//  Kurzwahl2020Tests
//
//  Created by Andreas Vogel on 01.02.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Kurzwahl2020

class ContactTest: XCTestCase {

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
    
    
    func testFetchcontacts() {
        let reader = contactReader()
        
        let myContacts = reader.contactsFromAddressBook()
        XCTAssertNotNil(myContacts)
        XCTAssertTrue( myContacts.count > 0)
    }

}

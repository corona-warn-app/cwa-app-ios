////
////  ContactTest.swift
////  Kurzwahl2020Tests
////
////  Created by Andreas Vogel on 01.02.20.
////  Copyright © 2020 Vogel, Andreas. All rights reserved.
////
//
//import XCTest
//@testable import Call_by_Color_36
//
//class ContactTest: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            fetchContacts()
//        }
//    }
//
//
//    func fetchContacts() {
//        let reader = contactReader()
//
//        let myContacts = reader.contactsFromAddressBook()
//        XCTAssertNotNil(myContacts)
//        XCTAssertTrue( myContacts.count > 0)
//
//        for contact in myContacts {
//            XCTAssertTrue(contact.phoneNumber.count > 0)
//            XCTAssertTrue(contact.label.count > 0)
//        }
//    }
//
//
//
//    func testUniqueContacts() {
//        let reader = contactReader()
//        let myContacts = reader.getUniqueContacts()
//        XCTAssertNotNil(myContacts)
//        XCTAssertTrue( myContacts.count > 0)
//    }
//
//
//    func testGetNumbersForContact() {
//        let reader = contactReader()
//        let myContacts = reader.contactsFromAddressBook()
//
//        struct test : Hashable {
//            var name : String
//            var count : Int
//        }
//        var testSet = Set<test>()
//
//        var i : Int = 0
//        var lastname : String = ""
//        for contact in myContacts {
//            if lastname == "" {
//                lastname = contact.name
//                i = 1
//            } else if lastname != contact.name {
//                testSet.insert(test(name: lastname, count: i))
//                XCTAssertTrue(reader.getNumberOfPhoneNumbers(forContactName: lastname) == i)
//
//                lastname = contact.name
//                i = 1
//            } else if lastname == contact.name{
//                i += 1
//            }
//        }
//
//
//    }
//
//
//}

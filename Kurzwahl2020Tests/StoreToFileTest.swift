//
//  StoreToFileTest.swift
//  Kurzwahl2020Tests
//
//  Created by Andreas Vogel on 11.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Call_by_Color_36

let APPGROUP : String = "group.org.tcfos.callbycolor"

class StoreToFileTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func persistStruct() {
        struct person {
            var id: Int
            var name: String
            var phoneNumber: String
        }
        
        
        let filename : String = "structTestStore"
        let aPerson = person(id: 0, name: "Alpha", phoneNumber: "+49621777777")
        
        
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent(filename)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: aPerson, requiringSecureCoding: true).write(to: fullPath)
        } catch {
            print("Store of a struct failed")
        }
    }
    
    
    func readStruct() {
        struct person {
            var id: Int
            var name: String
            var phoneNumber: String
        }
        
        let filename : String = "structTestStore"
        let aPerson = person(id: 0, name: "Alpha", phoneNumber: "+49621777777")
        var result = person(id: 1, name: "", phoneNumber: "")
        
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent(filename)
        do {
        let data = try Data(contentsOf: fullPath)
            result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as! person
        } catch {
            print("reading a struct failed")
        }
        
        XCTAssertTrue(result.id == aPerson.id)
        XCTAssertTrue(result.name == aPerson.name)
        XCTAssertTrue(result.phoneNumber == aPerson.phoneNumber)
    }
    
    
    
}


    extension FileManager {
      static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(
          forSecurityApplicationGroupIdentifier: APPGROUP
        )!
      }
    }


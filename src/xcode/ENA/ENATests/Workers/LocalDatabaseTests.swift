//
//  LocalDatabaseTests.swift
//  ENATests
//
//  Created by Bormeth, Marc on 20.05.20.
//

import XCTest
import ExposureNotification
@testable import ENA

final class LocalDatabaseTests: XCTestCase {
    var db: LocalDatabase!

    override func setUp() {
        super.setUp()
        db = LocalDatabase(with: URL(staticString: "file::memory:"))
    }

    func testSuccess() {
        let data = Data(bytes: [7, 13, 42], count: 3)
        let date = "1994-10-13"
        let hour: Int? = 6

        // Insert data
        db.storePayload(payload: data, day: date, hour: hour)

        // Retrieve
        let result = db.fetchPayloads()

        // Validate
        XCTAssertNotNil(result, "Result nil")
        XCTAssertNotNil(result?.first, "Result empty")

        XCTAssertEqual(result?.first?.data, data)
        XCTAssertEqual(result?.first?.day, date)
    }

    func testFailure() {
        let data = Data(bytes: [0, 0, 1], count: 3)
        let date = "9️⃣.7️⃣.🔟"
        let hour: Int? = 6

        // Insert data
        db.storePayload(payload: data, day: date, hour: hour)

        // Retrieve
        let result = db.fetchPayloads()

        // Validate
        XCTAssertNil(result?.first, "Result not empty")
    }

}

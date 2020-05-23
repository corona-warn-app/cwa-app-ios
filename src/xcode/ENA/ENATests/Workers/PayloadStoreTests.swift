//
//  LocalDatabaseTests.swift
//  ENATests
//
//  Created by Bormeth, Marc on 20.05.20.
//

import XCTest
import ExposureNotification
@testable import ENA

final class PayloadStoreTests: XCTestCase {
    var db: FMDBPayloadStore!

    override func setUp() {
        super.setUp()
        db = FMDBPayloadStore(with: URL(staticString: "file::memory:"))
    }

    func testRoundtripSuccess() {
        let data = Data(bytes: [7, 13, 42, 19, 23], count: 5)
        let signature = Data(bytes: [1, 2, 3], count: 3)
        let day = Date()
        let hour: Int? = 6
        let payload = LocalPayloadStore.StoredPayload(data: data, signature: signature, day: day, hour: hour)

        // Insert data
        db.storePayload(payload: payload)

        // Retrieve
        let result = db.fetchPayloads()

        // Validate
        XCTAssertNotNil(result.first, "Result empty")

        XCTAssertEqual(result.first?.data, data)
        XCTAssertEqual(result.first?.day.timeIntervalSince1970, day.timeIntervalSince1970)
    }

    func testRoundtripFailure() {
        // Retrieve without inserting any data
        let result = db.fetchPayloads()

        // Validate
        XCTAssertNil(result.first, "Result not empty")
    }

    func testStoredKeysSuccess() {
        // Add timeintervals for 6 days
        var timeIntervals = [Double]()
        for i in 0...5 {
            timeIntervals.append(Double(i * -86400))
        }

        // Store a day package + an hour package for each of the 6 days
        for interval in timeIntervals {
            let data = Data(bytes: [0, 0, 1, 0, 0], count: 5)
            let signature = Data(bytes: [1, 1, 0], count: 3)
            let day = Date(timeIntervalSinceNow: interval)
            log(message: day.description(with: nil))
            let hour = 7
            var payload = LocalPayloadStore.StoredPayload(data: data, signature: signature, day: day, hour: hour)

            db.storePayload(payload: payload)

            payload.hour = nil
            db.storePayload(payload: payload)
        }

        let storedDays = db.storedDays()
        XCTAssertEqual(storedDays.count, 6)
    }

}

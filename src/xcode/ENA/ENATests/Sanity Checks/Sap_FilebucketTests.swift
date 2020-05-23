//
//  Sap_FilebucketTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
@testable import ENA
import XCTest

final class SapFileBucketTests: XCTestCase {
    func testDataFromBackend() throws {
        let bundle = Bundle(for: SapFileBucketTests.self)

        let fixtureUrl = bundle.url(
            forResource: "2020-04-27-full-day-from-sap-api",
            withExtension: "proto"
        )!

        let fixtureData = try Data(contentsOf: fixtureUrl)
        let bucket = try SAPKeyPackage(serializedSignedPayload: fixtureData)

        let files =  bucket.files
        XCTAssertEqual(files.count, 24)
    }
}

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
            forResource: "api-response-day-2020-05-16",
            withExtension: nil
            )!
        
        let fixtureData = try Data(contentsOf: fixtureUrl)
        let bucket = SAPDownloadedPackage(compressedData: fixtureData)
        XCTAssertNotNil(bucket)
    }
}

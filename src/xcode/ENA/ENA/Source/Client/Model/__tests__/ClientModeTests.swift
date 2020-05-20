//
//  EnvironmentTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import XCTest
@testable import ENA

final class ClientModeTests: XCTestCase {
    func testModeFromEnvironmentDictionary() {
        XCTAssertEqual(
            ClientMode.from(environment: ["CWA_CLIENT_MODE": "mock"]).rawValue,
            ClientMode.mock.rawValue
        )
        XCTAssertEqual(
            ClientMode.from(environment: ["CWA_CLIENT_MODE": "https"]).rawValue,
            ClientMode.https.rawValue
        )

        // Defaults to https
        XCTAssertEqual(
            ClientMode.from(environment: ["CWA_CLIENT_MODE": "xxx"]).rawValue,
            ClientMode.https.rawValue
        )

        XCTAssertEqual(
            ClientMode.from(environment: [:]).rawValue,
            ClientMode.https.rawValue
        )
    }
}

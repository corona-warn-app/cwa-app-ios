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

final class ModeTests: XCTestCase {
    func testModeFromEnvironmentDictionary() {
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "https"]).rawValue,
            Mode.https.rawValue
        )
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "mock"]).rawValue,
            Mode.mock.rawValue
        )
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "xxx"]).rawValue,
            Mode.https.rawValue
        )
        XCTAssertEqual(
            Mode.from(environment: [:]).rawValue,
            Mode.https.rawValue
        )
    }
}


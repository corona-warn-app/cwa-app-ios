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
    func testModeFromEnvironmentDictionary_Production() {
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "production"]).rawValue,
            Mode.production.rawValue
        )
    }

    func testModeFromEnvironmentDictionary_Development() {
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "development"]).rawValue,
            Mode.development.rawValue
        )
    }

    func testModeFromEnvironmentDictionary_Mock() {
        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "mock"]).rawValue,
            Mode.mock.rawValue
        )
    }

    func testModeFromEnvironmentDictionary_DefaultsToMock() {
        XCTAssertEqual(
            Mode.from(environment: [:]).rawValue,
            Mode.mock.rawValue
        )

        XCTAssertEqual(
            Mode.from(environment: ["CW_MODE": "xxx"]).rawValue,
            Mode.mock.rawValue
        )
    }
}


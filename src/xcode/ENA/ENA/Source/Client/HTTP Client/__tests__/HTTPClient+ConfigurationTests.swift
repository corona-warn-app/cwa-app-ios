//
//  BackendConfigurationTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import XCTest
@testable import ENA

final class BackendConfigurationTests: XCTestCase {
    private typealias Configuration = HTTPClient.Configuration
    private typealias Endpoint = HTTPClient.Configuration.Endpoint

    func testConfiguration() {
        let distribution = Endpoint(
            baseURL: URL(staticString: "http://localhost/dist"),
            requiresTrailingSlash: true
        )

        let submission = Endpoint(
            baseURL: URL(staticString: "http://localhost/submit"),
            requiresTrailingSlash: true
        )

        let endpoints = Configuration.Endpoints(
            distribution: distribution,
            submission: submission
        )

        let config = Configuration(
            apiVersion: "v1",
            country: "DE",
            endpoints: endpoints
        )

        // Diagnosis Keys URL
        XCTAssertEqual(
            config.diagnosisKeysURL.absoluteString,
            "http://localhost/dist/version/v1/diagnosis-keys/country/DE/"
        )

        // Check Configuration URL
        XCTAssertEqual(
            config.configurationURL.absoluteString,
            "http://localhost/dist/version/v1/parameters/country/DE/"
        )

        // Submission URL
        XCTAssertEqual(
            config.submissionURL.absoluteString,
            "http://localhost/submit/version/v1/diagnosis-keys/"
        )

        // Hour URL
        XCTAssertEqual(
            config.diagnosisKeysURL(day: "2020-04-20", hour: 14).absoluteString,
            "http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/hour/14/"
        )

        // Day URL
        XCTAssertEqual(
            config.diagnosisKeysURL(day: "2020-04-20").absoluteString,
            "http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/"
        )

        // Available Days URL
        XCTAssertEqual(
            config.availableDaysURL.absoluteString,
            "http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/"
        )

        // Available Hours for a given Day URL
        XCTAssertEqual(
            config.availableHoursURL(day: "2020-04-20").absoluteString,
            "http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/hour/"
        )
    }
}

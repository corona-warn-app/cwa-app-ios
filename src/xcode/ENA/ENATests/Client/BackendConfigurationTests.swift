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
    func testDiagnosisKeysURL() {
        let base = URL(string: "http://localhost:8080/covid")!

        let config = BackendConfiguration(
            apiVersion: "v1",
            country: "DE",
            endpoints: .init(distribution: base, submission: base)
        )

        XCTAssertEqual(
            config.diagnosisKeysURL,
            URL(string: "http://localhost:8080/covid/version/v1/diagnosis-keys/")!
        )
    }

    func testRegionalDiagnosisKeysURL() {
           let base = URL(string: "http://localhost:8080/covid")!

           let config = BackendConfiguration(
               apiVersion: "v1",
               country: "DE",
               endpoints: .init(distribution: base, submission: base)
           )

           XCTAssertEqual(
               config.regionalDiagnosisKeysURL,
               URL(staticString: "http://localhost:8080/covid/version/v1/diagnosis-keys/country/DE/")
           )
       }
}

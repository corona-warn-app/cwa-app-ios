//
//  ExposureWindowTest.swift
//  ENATests
//
//  Created by Kai-Marcel Teuber on 31.10.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
import ExposureNotification
@testable import ENA

class ExposureWindowTest: XCTestCase {

	func testGIVEN_jsonExposureWindow_WHEN_converted_THEN_DateMatches() {
		// GIVEN
		let exposureWindow = RiskHelpers.ExposureWindow(
			ageInDays: 1,
			reportType: 2,
			infectiousness: 2,
			calibrationConfidence: 0,
			scanInstances: []
		)

		// WHEN
		let realExposureWindow = exposureWindow.exposureWindow

		// THEN
		guard let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
			XCTFail("Expected date missing - stop test")
			return
		}
		XCTAssert(Calendar.current.isDate(realExposureWindow.date, inSameDayAs: expectedDate))
		XCTAssertEqual(realExposureWindow.reportType, .confirmedClinicalDiagnosis)
		XCTAssertEqual(realExposureWindow.infectiousness, .high)
		XCTAssertEqual(realExposureWindow.calibrationConfidence, .lowest)
	}

}

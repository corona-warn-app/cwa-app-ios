//
// 🦠 Corona-Warn-App
//


import XCTest
import ExposureNotification
@testable import ENA

class ExposureWindowTest: XCTestCase {

	func testGIVEN_JsonExposureWindowWithAge1_WHEN_Converted_THEN_ValueMatch() throws {
		// GIVEN
		let jsonData = """
			{
			  "ageInDays": 1,
			  "reportType": 2,
			  "infectiousness": 2,
			  "calibrationConfidence": 0,
			  "scanInstances": [
				{
				  "typicalAttenuation": 30,
				  "minAttenuation": 25,
				  "secondsSinceLastScan": 300
				},
				{
				  "typicalAttenuation": 30,
				  "minAttenuation": 25,
				  "secondsSinceLastScan": 299
				}
			  ]
			}
		""".data(using: .utf8)


		// WHEN
		let exposureWindow = try JSONDecoder().decode(ExposureWindow.self, from: XCTUnwrap(jsonData))

		// THEN
		guard let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
			XCTFail("Expected date missing - stop test")
			return
		}

		XCTAssertTrue(Calendar.current.isDate(exposureWindow.date, inSameDayAs: expectedDate))
		XCTAssertEqual(exposureWindow.reportType, .confirmedClinicalDiagnosis)
		XCTAssertEqual(exposureWindow.infectiousness, .high)
		XCTAssertEqual(exposureWindow.calibrationConfidence, .lowest)

		XCTAssertEqual(exposureWindow.scanInstances.count, 2)
	}

	func testGIVEN_JsonExposureWindowWithAge3_WHEN_Converted_THEN_ValuesMatch() throws {
		// GIVEN
		let jsonData = """
		{
		  "ageInDays": 3,
		  "reportType": 1,
		  "infectiousness": 1,
		  "calibrationConfidence": 1,
		  "scanInstances": [
			{
			  "typicalAttenuation": 17,
			  "minAttenuation": 99,
			  "secondsSinceLastScan": 765
			}
		  ]
		}
		""".data(using: .utf8)


		// WHEN
		let exposureWindow = try JSONDecoder().decode(ExposureWindow.self, from: XCTUnwrap(jsonData))

		// THEN
		guard let expectedDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) else {
			XCTFail("Expected date missing - stop test")
			return
		}

		XCTAssertTrue(Calendar.current.isDate(exposureWindow.date, inSameDayAs: expectedDate))
		XCTAssertEqual(exposureWindow.reportType, .confirmedTest)
		XCTAssertEqual(exposureWindow.infectiousness, .standard)
		XCTAssertEqual(exposureWindow.calibrationConfidence, .low)

		XCTAssertEqual(exposureWindow.scanInstances.count, 1)
	}

}

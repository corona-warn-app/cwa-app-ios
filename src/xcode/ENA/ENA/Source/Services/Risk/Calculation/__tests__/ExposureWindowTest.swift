//
// 🦠 Corona-Warn-App
//


import XCTest
import ExposureNotification
@testable import ENA

class ExposureWindowTest: CWATestCase {

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
	
	func test_Age_Todays_ExposureWindow() throws {
		let windowDate = try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-10T00:00:00Z"))
		let todayDate = try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-10T13:00:00Z"))
		let window = ExposureWindow(
			calibrationConfidence: try XCTUnwrap(ENCalibrationConfidence(rawValue: 1)),
			date: windowDate,
			reportType: try XCTUnwrap(ENDiagnosisReportType(rawValue: 1)),
			infectiousness: try XCTUnwrap(ENInfectiousness(rawValue: 1)),
			scanInstances: []
		)
		
		let age = window.age(from: todayDate)
		
		XCTAssertEqual(age, 0)
	}
	
	func test_Age_Yesterdays_ExposureWindow() throws {
		let windowDate = try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-09T00:00:00Z"))
		let todayDate = try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-10T13:00:00Z"))
		let window = ExposureWindow(
			calibrationConfidence: try XCTUnwrap(ENCalibrationConfidence(rawValue: 1)),
			date: windowDate,
			reportType: try XCTUnwrap(ENDiagnosisReportType(rawValue: 1)),
			infectiousness: try XCTUnwrap(ENInfectiousness(rawValue: 1)),
			scanInstances: []
		)
		
		let age = window.age(from: todayDate)
		
		XCTAssertEqual(age, 1)
	}
	
	func test_ExposureWindow_AgeFilter() throws {
		let windows = [
			ExposureWindow(
				calibrationConfidence: try XCTUnwrap(ENCalibrationConfidence(rawValue: 1)),
				date: try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-09T00:00:00Z")),
				reportType: try XCTUnwrap(ENDiagnosisReportType(rawValue: 1)),
				infectiousness: try XCTUnwrap(ENInfectiousness(rawValue: 1)),
				scanInstances: []
			),
			ExposureWindow(
				calibrationConfidence: try XCTUnwrap(ENCalibrationConfidence(rawValue: 1)),
				date: try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-10T00:00:00Z")),
				reportType: try XCTUnwrap(ENDiagnosisReportType(rawValue: 1)),
				infectiousness: try XCTUnwrap(ENInfectiousness(rawValue: 1)),
				scanInstances: []
			),
			ExposureWindow(
				calibrationConfidence: try XCTUnwrap(ENCalibrationConfidence(rawValue: 1)),
				date: try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-11T00:00:00Z")),
				reportType: try XCTUnwrap(ENDiagnosisReportType(rawValue: 1)),
				infectiousness: try XCTUnwrap(ENInfectiousness(rawValue: 1)),
				scanInstances: []
			)
		]
		
		let now = try XCTUnwrap(ExposureWindowTest.utcFormatter.date(from: "2022-03-11T13:00:00Z"))
		// 1 of the 3 ExposureWindows is 2 days old and gets filtered by maxEncounterAgeInDays = 1
		let filteredWindows = windows.filteredByAge(maxEncounterAgeInDays: 1, now: now)
		XCTAssertEqual(filteredWindows.count, 2)
	}

	fileprivate static let utcFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
}

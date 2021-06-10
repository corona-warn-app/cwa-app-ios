//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckInTests: CWATestCase {

	func testWHEN_LoadingJsonTestFile_THEN_AllTestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = testCasesWithConfiguration.testCases

		// THEN
		XCTAssertEqual(testCases.count, 10)
	}

	func testGIVEN_TestCases_WHEN_DerivingWarningTimeInterval_THEN_ResultIsCorrect() {
		// GIVEN
		let testCases = testCasesWithConfiguration.testCases

		for testCase in testCases {
			// WHEN
			let checkin = Checkin.mock(
				checkinStartDate: testCase.startDate,
				checkinEndDate: testCase.endDate
			)

			let derivedCheckin = checkin.derivingWarningTimeInterval(config: testCasesWithConfiguration.defaultConfiguration)

			// THEN
			XCTAssertEqual(derivedCheckin?.checkinStartDate, testCase.expStartDate)
			XCTAssertEqual(derivedCheckin?.checkinEndDate, testCase.expEndDate)
		}
	}

	func testPrepareCheckinForSubmission() throws {
		let traceLocationId = "asdf".data(using: .utf8) ?? Data()

		// create a mock checkin and check preconditions
		for i in stride(from: 1, to: 600, by: 10) {
			let checkin = Checkin.mock(
				traceLocationId: traceLocationId,
				checkinStartDate: Date(timeIntervalSinceNow: -(Double(i * 10))),
				checkinEndDate: Date()
			)
			XCTAssertGreaterThan(checkin.checkinEndDate, checkin.checkinStartDate)

			let transformedCheckin = checkin.prepareForSubmission()
			XCTAssertGreaterThanOrEqual(transformedCheckin.endIntervalNumber, transformedCheckin.startIntervalNumber)

			// check calculated interval numbers and compare to start/end dates
			XCTAssertEqual(
				TimeInterval(transformedCheckin.startIntervalNumber * 600),
				checkin.checkinStartDate.timeIntervalSince1970,
				accuracy: 600
			)

			XCTAssertEqual(
				TimeInterval(transformedCheckin.endIntervalNumber * 600),
				checkin.checkinEndDate.timeIntervalSince1970,
				accuracy: 600
			)

			XCTAssertEqual(transformedCheckin.locationID, traceLocationId)
		}
	}

	func testCheckinTransformationWithTraceLocationStartAndEndDate() throws {
		// create a mock checkin and check preconditions
		let startDate = Date(timeIntervalSinceNow: -200)
		let endDate = Date(timeIntervalSinceNow: 200)

		let checkin = Checkin.mock(
			traceLocationId: "traceLocationId".data(using: .utf8) ?? Data(),
			traceLocationVersion: 17,
			traceLocationDescription: "Description",
			traceLocationAddress: "Address",
			traceLocationStartDate: startDate,
			traceLocationEndDate: endDate
		)

		let protobufTraceLocation = checkin.traceLocation

		XCTAssertEqual(protobufTraceLocation.version, 17)
		XCTAssertEqual(protobufTraceLocation.description_p, "Description")
		XCTAssertEqual(protobufTraceLocation.address, "Address")
		XCTAssertEqual(protobufTraceLocation.startTimestamp, UInt64(startDate.timeIntervalSince1970))
		XCTAssertEqual(protobufTraceLocation.endTimestamp, UInt64(endDate.timeIntervalSince1970))
	}

	func testCheckinTransformationWithoutTraceLocationStartAndEndDate() throws {
		// create a mock checkin and check preconditions
		let checkin = Checkin.mock(
			traceLocationId: "traceLocationId".data(using: .utf8) ?? Data(),
			traceLocationVersion: 17,
			traceLocationDescription: "Description",
			traceLocationAddress: "Address",
			traceLocationStartDate: nil,
			traceLocationEndDate: nil
		)

		let protobufTraceLocation = checkin.traceLocation

		XCTAssertEqual(protobufTraceLocation.version, 17)
		XCTAssertEqual(protobufTraceLocation.description_p, "Description")
		XCTAssertEqual(protobufTraceLocation.address, "Address")
		XCTAssertEqual(protobufTraceLocation.startTimestamp, 0)
		XCTAssertEqual(protobufTraceLocation.endTimestamp, 0)
	}

	// MARK: - Private

	private lazy var testCasesWithConfiguration: CheckinTestCasesWithConfiguration = {
		let testBundle = Bundle(for: CheckinTests.self)
		guard let urlJsonFile = testBundle.url(forResource: "checkin-timeinterval-derivation", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			fatalError("Failed init json file for tests - stop here")
		}

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmXXXXX"

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(dateFormatter)

		do {
			return try decoder.decode(CheckinTestCasesWithConfiguration.self, from: data)
		} catch let DecodingError.keyNotFound(jsonKey, context) {
			fatalError("missing key: \(jsonKey)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			fatalError("Type not found \(type)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(type, context) {
			fatalError("Type mismatch found \(type)\nDebug Description: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			fatalError("Debug Description: \(context.debugDescription) \(context)")
		} catch {
			fatalError("Failed to parse JSON answer")
		}
	}()

}

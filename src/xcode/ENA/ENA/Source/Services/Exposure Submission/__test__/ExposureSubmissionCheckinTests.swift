////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinTests: XCTestCase {

    func testCheckinTransmissionPreparation() throws {
        let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let checkin = Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: [checkin],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 5)

		XCTAssertEqual(preparedCheckins[0].transmissionRiskLevel, 4)
		XCTAssertEqual(preparedCheckins[1].transmissionRiskLevel, 6)
		XCTAssertEqual(preparedCheckins[2].transmissionRiskLevel, 7)
		XCTAssertEqual(preparedCheckins[3].transmissionRiskLevel, 8)
		XCTAssertEqual(preparedCheckins[4].transmissionRiskLevel, 8)

		waitForExpectations(timeout: .short)
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
}

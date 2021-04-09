////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinTests: XCTestCase {

    func testCheckinTransmissionPreparation() throws {
        let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		))

		// process checkins
		let processingDone = expectation(description: "processing done")
		service.preparedCheckinsForSubmission(
			with: eventStore,
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		) { checkins in
			XCTAssertEqual(checkins.count, 5)

			XCTAssertEqual(checkins[0].transmissionRiskLevel, 4)
			XCTAssertEqual(checkins[1].transmissionRiskLevel, 6)
			XCTAssertEqual(checkins[2].transmissionRiskLevel, 7)
			XCTAssertEqual(checkins[3].transmissionRiskLevel, 8)
			XCTAssertEqual(checkins[4].transmissionRiskLevel, 8)

			processingDone.fulfill()
		}

		waitForExpectations(timeout: .short)
		eventStore.cleanup()
    }

	func testDerivingWarningTimeInterval() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startOfToday = Calendar.current.startOfDay(for: Date())

		let filteredStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 1, to: startOfToday))
		let filteredEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 8, to: filteredStartDate))

		let keptStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 0, to: startOfToday))
		let keptEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 10, to: keptStartDate))
		let derivedEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 20, to: keptStartDate))

		let expectedStartIntervalNumber = UInt32(keptStartDate.timeIntervalSince1970 / 600)
		let expectedEndIntervalNumber = UInt32(derivedEndDate.timeIntervalSince1970 / 600)

		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(
			checkinStartDate: filteredStartDate,
			checkinEndDate: filteredEndDate
		))

		eventStore.createCheckin(Checkin.mock(
			checkinStartDate: keptStartDate,
			checkinEndDate: keptEndDate
		))

		// process checkins
		let processingDone = expectation(description: "processing done")
		service.preparedCheckinsForSubmission(
			with: eventStore,
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		) { checkins in
			XCTAssertEqual(checkins.count, 1)

			XCTAssertEqual(checkins[0].startIntervalNumber, expectedStartIntervalNumber)
			XCTAssertEqual(checkins[0].endIntervalNumber, expectedEndIntervalNumber)

			processingDone.fulfill()
		}

		waitForExpectations(timeout: .short)
		eventStore.cleanup()
	}

}

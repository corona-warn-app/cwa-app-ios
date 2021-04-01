////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinTests: XCTestCase {

    func testCheckinTransmissionPreparation() throws {
        let service = MockExposureSubmissionService()
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()

		let eventStore = try XCTUnwrap(EventStore(url: EventStore.storeURL))

		// create dummy data
		(0...3).forEach { _ in
			let result = eventStore.createCheckin(Checkin.mock())
			switch result {
			case .success:
				break
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}

		debugPrint(eventStore.checkinsPublisher.value)

		// process checkins
		let processingDone = expectation(description: "processing done")
		service.preparedCheckinsForSubmission(with: appConfig, symptomOnset: .noInformation) { checkins in
			XCTAssertEqual(checkins.count, 2)
			processingDone.fulfill()
		}

		waitForExpectations(timeout: .short)
		eventStore.cleanup()
    }

	func testCheckinTransformation() throws {
		// create a mock checkin and check preconditions

		for i in stride(from: 1, to: 600, by: 10) {
			let checkin = Checkin.mock(
				checkinStartDate: Date(timeIntervalSinceNow: -(Double(i * 10))),
				checkinEndDate: Date()
			)
			XCTAssertGreaterThan(checkin.checkinEndDate, checkin.checkinStartDate)
			XCTAssertGreaterThanOrEqual(try XCTUnwrap(checkin.traceLocationEndDate), try XCTUnwrap(checkin.traceLocationEndDate))

			let transformed = checkin.prepareForSubmission()
			XCTAssertTrue(type(of: transformed) == SAP_Internal_Pt_CheckIn.self)
			XCTAssertGreaterThanOrEqual(transformed.endIntervalNumber, transformed.startIntervalNumber)

			// check calculated interval numbers and compare to star/end dates
			XCTAssertEqual(
				TimeInterval(transformed.startIntervalNumber * 600),
				checkin.checkinStartDate.timeIntervalSince1970,
				accuracy: 600)

			XCTAssertEqual(
				TimeInterval(transformed.startIntervalNumber * 600),
				checkin.checkinStartDate.timeIntervalSince1970,
				accuracy: 600)

			// trace location conversion
			let location = checkin.traceLocation
			XCTAssertEqual(TimeInterval(location.startTimestamp), checkin.checkinStartDate.timeIntervalSince1970)
			XCTAssertEqual(TimeInterval(location.endTimestamp), checkin.checkinEndDate.timeIntervalSince1970)
		}
	}
}

////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinTests: XCTestCase {

	func test_When_DifferenceIs0m_Then_RoundedTo0() {
		guard
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = makeDummyCheckin(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		XCTAssertEqual(checkin.roundedDurationIn15mSteps, 0)
	}

	func test_When_DifferenceIs7m_Then_RoundedTo0() {
		guard
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:37:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = makeDummyCheckin(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		XCTAssertEqual(checkin.roundedDurationIn15mSteps, 0)
	}

	func test_When_DifferenceIs7Dot5m_Then_RoundedTo15() {
		guard
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:37:30+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = makeDummyCheckin(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		XCTAssertEqual(checkin.roundedDurationIn15mSteps, 15)
	}

	func test_When_DifferenceIs22m_Then_RoundedTo15() {
		guard
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:52:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = makeDummyCheckin(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		XCTAssertEqual(checkin.roundedDurationIn15mSteps, 15)
	}

	func test_When_DifferenceIs22Dot5m_Then_RoundedTo30() {
		guard
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:52:30+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = makeDummyCheckin(
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		XCTAssertEqual(checkin.roundedDurationIn15mSteps, 30)
	}

	func makeDummyCheckin(
		id: Int = 42,
		checkinStartDate: Date = Date(),
		checkinEndDate: Date = Date(),
		checkinCompleted: Bool = false,
		targetCheckinEndDate: Date = Date(),
		traceLocationId: Data = "0".data(using: .utf8) ?? Data(),
		traceLocationDescription: String = "",
		traceLocationAddress: String = "",
		traceLocationStartDate: Date = Date(),
		traceLocationEndDate: Date = Date()
	) -> Checkin {
		Checkin(
			id: id,
			traceLocationId: traceLocationId,
			traceLocationIdHash: traceLocationId,
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentCraft,
			traceLocationDescription: traceLocationDescription,
			traceLocationAddress: traceLocationAddress,
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: 0,
			cryptographicSeed: Data(),
			cnPublicKey: Data(),
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: checkinCompleted,
			createJournalEntry: true
		)
	}

	var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
}

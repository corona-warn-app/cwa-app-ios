////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// Test scenarios from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/a053f23d4d33721ac98f70ccc05175fbcfc35632/test-cases/pt-split-check-in-by-midnight-utc-data.json

class CheckinSplittingServiceTests: XCTestCase {

	// does not split check-in with same start and end time
	func test_Scenario1() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 1)

		let splitedCheckinStartDate = splitedCheckins[0].checkinStartDate

		guard let splitedCheckinEndDate = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinStartDate))
		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinEndDate))
	}

	// does not split check-in with start and end on the same day
	func test_Scenario2() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:45:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 1)

		let splitedCheckinStartDate = splitedCheckins[0].checkinStartDate

		guard let splitedCheckinEndDate = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinStartDate))
		XCTAssertEqual("2021-03-04T08:45:00Z", utcFormatter.string(from: splitedCheckinEndDate))
	}

	// splits a 2-day check-in by midnight UTC
	func test_Scenario3() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-05T09:45:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 2)

		let splitedCheckinStartDate0 = splitedCheckins[0].checkinStartDate
		guard let splitedCheckinEndDate0 = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		let splitedCheckinStartDate1 = splitedCheckins[1].checkinStartDate
		guard let splitedCheckinEndDate1 = splitedCheckins[1].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinStartDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinEndDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinStartDate1))
		XCTAssertEqual("2021-03-05T08:45:00Z", utcFormatter.string(from: splitedCheckinEndDate1))
	}

	// splits a 3-day check-in by midnight UTC
	func test_Scenario4() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-06T09:45:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 3)

		let splitedCheckinStartDate0 = splitedCheckins[0].checkinStartDate
		guard let splitedCheckinEndDate0 = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}
		let splitedCheckinStartDate1 = splitedCheckins[1].checkinStartDate
		guard let splitedCheckinEndDate1 = splitedCheckins[1].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}
		let splitedCheckinStartDate2 = splitedCheckins[2].checkinStartDate
		guard let splitedCheckinEndDate2 = splitedCheckins[2].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinStartDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinEndDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinStartDate1))
		XCTAssertEqual("2021-03-06T00:00:00Z", utcFormatter.string(from: splitedCheckinEndDate1))
		XCTAssertEqual("2021-03-06T00:00:00Z", utcFormatter.string(from: splitedCheckinStartDate2))
		XCTAssertEqual("2021-03-06T08:45:00Z", utcFormatter.string(from: splitedCheckinEndDate2))
	}

	// does not split check-in with start at midnight UTC and end on the same day
	func test_Scenario5() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T00:00:00+00:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:00:00+00:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 1)

		let splitedCheckinStartDate0 = splitedCheckins[0].checkinStartDate
		guard let splitedCheckinEndDate0 = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T00:00:00Z", utcFormatter.string(from: splitedCheckinStartDate0))
		XCTAssertEqual("2021-03-04T09:00:00Z", utcFormatter.string(from: splitedCheckinEndDate0))
	}

	// does not split check-in with end at midnight UTC and start on the same day before
	func test_Scenario6() {
		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:00:00+00:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-05T00:00:00+00:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 1)

		let splitedCheckinStartDate0 = splitedCheckins[0].checkinStartDate
		guard let splitedCheckinEndDate0 = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T09:00:00Z", utcFormatter.string(from: splitedCheckinStartDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinEndDate0))
	}

	// splits a 2-day check-in by midnight UTC if the duration is less than 24 hours
	func test_Scenario7() {

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-05T09:15:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let splittingService = CheckinSplittingService()
		let checkin = makeDummyCheckin(id: 0, startDate: checkinStartDate, endDate: checkinEndDate)

		let splitedCheckins = splittingService.split(checkin)
		XCTAssertEqual(splitedCheckins.count, 2)

		let splitedCheckinStartDate0 = splitedCheckins[0].checkinStartDate
		guard let splitedCheckinEndDate0 = splitedCheckins[0].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		let splitedCheckinStartDate1 = splitedCheckins[1].checkinStartDate
		guard let splitedCheckinEndDate1 = splitedCheckins[1].checkinEndDate else {
			XCTFail("checkinEndDate should not be nil")
			return
		}

		XCTAssertEqual("2021-03-04T08:30:00Z", utcFormatter.string(from: splitedCheckinStartDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinEndDate0))
		XCTAssertEqual("2021-03-05T00:00:00Z", utcFormatter.string(from: splitedCheckinStartDate1))
		XCTAssertEqual("2021-03-05T08:15:00Z", utcFormatter.string(from: splitedCheckinEndDate1))
	}

	func makeDummyCheckin(
		id: Int,
		startDate: Date = Date(),
		endDate: Date = Date(),
		traceLocationGUID: String = "0"
	) -> Checkin {
		Checkin(
			id: id,
			traceLocationGUID: traceLocationGUID,
			traceLocationVersion: 0,
			traceLocationType: .type1,
			traceLocationDescription: "",
			traceLocationAddress: "",
			traceLocationStartDate: Date(),
			traceLocationEndDate: Date(),
			traceLocationDefaultCheckInLengthInMinutes: 0,
			traceLocationSignature: "",
			checkinStartDate: startDate,
			checkinEndDate: endDate,
			targetCheckinEndDate: endDate,
			createJournalEntry: true
		)
	}

	var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
}

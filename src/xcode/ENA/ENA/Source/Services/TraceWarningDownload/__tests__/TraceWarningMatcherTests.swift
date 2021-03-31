////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// Test scenarios from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/test-cases/pt-calculate-overlap-data.json

// swiftlint:disable:next type_body_length
class TraceWarningMatcherTests: XCTestCase {

	// returns 0 if guids do not match
	func test_Scenario1() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:45:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "69eb427e1a48133970486244487e31b3f1c5bde47415db9b52cc5a2ece1e0060".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

	// returns 0 if guids do not match (but the time machtes)
	func test_Scenario1b() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T010:00:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "69eb427e1a48133970486244487e31b3f1c5bde47415db9b52cc5a2ece1e0060".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

	// returns 0 if check-in precedes warning
	func test_Scenario2() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T09:45:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

//	returns 0 if check-in is preceded by warning
	func test_Scenario3() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T11:15:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T11:20:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

//	returns 0 if check-in meets warning at the start
	func test_Scenario4() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

//	returns 0 if check-in meets warning at the end
	func test_Scenario5() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T11:00:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T11:10:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 0)
	}

//	returns overlap if check-in overlaps warning at the start
	func test_Scenario6() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:12:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)

		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 12)
	}

//	returns overlap if check-in overlaps warning at the end
	func test_Scenario7() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T10:45:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T11:12:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 15)
	}

//	returns overlap if check-in starts warning
	func test_Scenario8() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:13:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 13)
	}

//	returns overlap if check-in during warning
	func test_Scenario9() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T10:15:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:17:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 2)
	}

//	returns overlap if check-in finishes warning
	func test_Scenario10() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T10:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T11:00:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 30)
	}

//	returns overlap if check-in equals warning
	func test_Scenario11() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T11:00:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 60)
	}

//	returns overlap after rounding (up)
	func test_Scenario12() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:50:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:05:45+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 6)
	}

//	returns overlap after rounding (down)
	func test_Scenario13() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:50:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:05:15+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 1)
		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 5)
	}

	func test_When_MoreThenOneWarning_Then_MoreThenOneMatchPersisted() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:12:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning, warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 2)

		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 12)
	}

	func test_When_MoreThenOneCheckin_Then_MoreThenOneMatchPersisted() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:12:00+01:00"),
			  let warningStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)
		store.createCheckin(checkin)
		store.createCheckin(checkin)

		var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
		warning.locationIDHash = "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871".data(using: .utf8) ?? Data()
		warning.startIntervalNumber = create10MinutesInterval(from: warningStartDate)
		warning.period = 6
		warning.transmissionRiskLevel = 8

		let warnings = [warning]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)

		XCTAssertEqual(store.traceTimeIntervalMatchesPublisher.value.count, 2)

		let overlap = matcher.calculateOverlap(checkin: checkin, warning: warning)
		XCTAssertEqual(overlap, 12)
	}

	func test_When_OverlapWithMatch_Then_CorrectOverlapReturned() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		guard let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-04T10:12:00+01:00"),
			  let matchStartDate = utcFormatter.date(from: "2021-03-04T10:00:00+01:00"),
			  let matchEndDate = utcFormatter.date(from: "2021-03-04T11:00:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let checkin = createDummyCheckin(
			traceLocationIdHash: "",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate
		)

		let match = TraceTimeIntervalMatch(id: 0, checkinId: 0, traceWarningPackageId: 0, traceLocationId: Data(), transmissionRiskLevel: 0, startIntervalNumber: Int(create10MinutesInterval(from: matchStartDate)), endIntervalNumber: Int(create10MinutesInterval(from: matchEndDate)))

		let overlap = matcher.calculateOverlap(checkin: checkin, match: match)
		XCTAssertEqual(overlap, 12)
	}

	private func create10MinutesInterval(from date: Date) -> UInt32 {
		UInt32(date.timeIntervalSince1970 / 600)
	}

	private func createDummyCheckin(
		traceLocationIdHash: String,
		checkinStartDate: Date = Date(),
		checkinEndDate: Date = Date()
		) -> Checkin {
		Checkin(
			id: 0,
			traceLocationId: Data(),
			traceLocationIdHash: traceLocationIdHash.data(using: .utf8) ?? Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentCraft,
			traceLocationDescription: "",
			traceLocationAddress: "",
			traceLocationStartDate: Date(),
			traceLocationEndDate: Date(),
			traceLocationDefaultCheckInLengthInMinutes: 0,
			cryptographicSeed: Data(),
			cnPublicKey: Data(),
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: true,
			createJournalEntry: true)
	}

	private var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	// swiftlint:disable:next file_length
}

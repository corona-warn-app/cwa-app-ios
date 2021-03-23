////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

//{
//  "testCases": [
//	{
//	  "description": "returns 0 if guids do not match",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:30+01:00", "endDateStr": "2021-03-04 09:45+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "69eb427e1a48133970486244487e31b3f1c5bde47415db9b52cc5a2ece1e0060",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 0
//	},
//	{
//	  "description": "returns 0 if check-in precedes warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:30+01:00", "endDateStr": "2021-03-04 09:45+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 0
//	},
//	{
//	  "description": "returns 0 if check-in is preceded by warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 11:15+01:00", "endDateStr": "2021-03-04 11:20+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 0
//	},
//	{
//	  "description": "returns 0 if check-in meets warning at the start",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:30+01:00", "endDateStr": "2021-03-04 10:00+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 0
//	},
//	{
//	  "description": "returns 0 if check-in meets warning at the end",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 11:00+01:00", "endDateStr": "2021-03-04 11:10+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 0
//	},
//	{
//	  "description": "returns overlap if check-in overlaps warning at the start",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:30+01:00", "endDateStr": "2021-03-04 10:12+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 12
//	},
//	{
//	  "description": "returns overlap if check-in overlaps warning at the end",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 10:45+01:00", "endDateStr": "2021-03-04 11:12+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 15
//	},
//	{
//	  "description": "returns overlap if check-in starts warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 10:00+01:00", "endDateStr": "2021-03-04 10:13+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 13
//	},
//	{
//	  "description": "returns overlap if check-in during warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 10:15+01:00", "endDateStr": "2021-03-04 10:17+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 2
//	},
//	{
//	  "description": "returns overlap if check-in finishes warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 10:30+01:00", "endDateStr": "2021-03-04 11:00+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 30
//	},
//	{
//	  "description": "returns overlap if check-in equals warning",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 10:00+01:00", "endDateStr": "2021-03-04 11:00+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 60
//	},
//	{
//	  "description": "returns overlap after rounding (up)",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:50+01:00", "endDateStr": "2021-03-04 10:05:45+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 6
//	},
//	{
//	  "description": "returns overlap after rounding (down)",
//	  "checkIn": {
//		"traceLocationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startDateStr": "2021-03-04 09:50+01:00", "endDateStr": "2021-03-04 10:05:15+01:00"
//	  },
//	  "traceTimeIntervalWarning": {
//		"locationGuidHash": "fe84394e73838590cc7707aba0350c130f6d0fb6f0f2535f9735f481dee61871",
//		"startIntervalDateStr": "2021-03-04 10:00+01:00",
//		"period": 6,
//		"transmissionRiskLevel": 8
//	  },
//	  "exp": 5
//	}
//  ]
//}

class TraceWarningMatcherTests: XCTestCase {

	func test_When_PackageContainsDifferentTraceLocationsGUIDs_Then_OnlyMatchingCheckinsArePersisted() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher(eventStore: store)

		let warnings = [
			SAP_Internal_Pt_TraceTimeIntervalWarning(),
			SAP_Internal_Pt_TraceTimeIntervalWarning()
		]
		var warningPackage = SAP_Internal_Pt_TraceWarningPackage()
		warningPackage.timeIntervalWarnings.append(contentsOf: warnings)

		matcher.matchAndStore(package: warningPackage)
	}

	static func createDummyCheckin(traceLocationGUID: String) -> Checkin {
		Checkin(
			id: 0,
			traceLocationGUID: traceLocationGUID,
			traceLocationGUIDHash: traceLocationGUID.data(using: .utf8) ?? Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentCraft,
			traceLocationDescription: "",
			traceLocationAddress: "",
			traceLocationStartDate: Date(),
			traceLocationEndDate: Date(),
			traceLocationDefaultCheckInLengthInMinutes: 0,
			traceLocationSignature: "",
			checkinStartDate: Date(),
			checkinEndDate: Date(),
			checkinCompleted: true,
			createJournalEntry: true)
	}

}

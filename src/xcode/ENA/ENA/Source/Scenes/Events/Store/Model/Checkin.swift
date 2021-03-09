////
// 🦠 Corona-Warn-App
//

struct Checkin {

	let id: Int
	let traceLocationGUID: String
	let traceLocationVersion: Int
	let traceLocationType: TraceLocationType
	let traceLocationDescription: String
	let traceLocationAddress: String
	let traceLocationStart: Date
	let traceLocationEnd: Date
	let traceLocationDefaultCheckInLengthInMinutes: Int
	let traceLocationSignature: String
	let checkinStartDate: Date
	let checkinEndDate: Date
	let targetCheckinEndDate: Date
	let createJournalEntry: Bool
}

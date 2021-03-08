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
	var checkinEndDate: Date
	var targetCheckinEndDate: Date
	let createJournalEntry: Bool

	mutating func update(checkinEndDate: Date) {
		self.checkinEndDate = checkinEndDate
	}

	mutating func update(targetCheckinEndDate: Date) {
		self.targetCheckinEndDate = targetCheckinEndDate
	}
}

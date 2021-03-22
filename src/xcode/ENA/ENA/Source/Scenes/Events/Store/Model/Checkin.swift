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
	let traceLocationStartDate: Date?
	let traceLocationEndDate: Date?
	let traceLocationDefaultCheckInLengthInMinutes: Int?
	let traceLocationSignature: String
	let checkinStartDate: Date
	let checkinEndDate: Date?
	let targetCheckinEndDate: Date?
	let createJournalEntry: Bool
}

extension Checkin {
	var roundedDurationIn15mSteps: Int {
		let checkingEndDate = checkinEndDate ?? Date()
		let checkinDurationInM = (checkingEndDate - checkinStartDate) / 60
		let roundedDuration = Int(round(checkinDurationInM / 15) * 15)
		return roundedDuration
	}
}

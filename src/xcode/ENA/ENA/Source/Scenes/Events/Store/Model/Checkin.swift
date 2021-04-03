////
// 🦠 Corona-Warn-App
//

import Foundation

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

struct Checkin: Equatable {

	let id: Int
	let traceLocationId: Data
	let traceLocationIdHash: Data
	let traceLocationVersion: Int
	let traceLocationType: TraceLocationType
	let traceLocationDescription: String
	let traceLocationAddress: String
	let traceLocationStartDate: Date?
	let traceLocationEndDate: Date?
	let traceLocationDefaultCheckInLengthInMinutes: Int?
	let cryptographicSeed: Data
	let cnPublicKey: Data
	let checkinStartDate: Date
	let checkinEndDate: Date
	let checkinCompleted: Bool
	let createJournalEntry: Bool

}

extension Checkin {
	var roundedDurationIn15mSteps: Int {
		let checkinDurationInM = (checkinEndDate - checkinStartDate) / 60
		let roundedDuration = Int(round(checkinDurationInM / 15) * 15)
		return roundedDuration
	}

	func completedCheckin(checkinEndDate: Date) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationId: self.traceLocationId,
			traceLocationIdHash: self.traceLocationIdHash,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: self.cryptographicSeed,
			cnPublicKey: self.cnPublicKey,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: true,
			createJournalEntry: self.createJournalEntry)
	}
}

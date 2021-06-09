////
// 🦠 Corona-Warn-App
//

extension Checkin {

	func updatedCheckin(
		checkinStartDate: Date? = nil,
		checkinEndDate: Date? = nil,
		checkinCompleted: Bool? = nil,
		checkinSubmitted: Bool? = nil,
		createJournalEntry: Bool? = nil
	) -> Checkin {

		let updatedCheckinStartDate: Date
		if let checkinStartDate = checkinStartDate {
			updatedCheckinStartDate = checkinStartDate
		} else {
			updatedCheckinStartDate = self.checkinStartDate
		}

		let updatedCheckinEndDate: Date
		if let checkinEndDate = checkinEndDate {
			updatedCheckinEndDate = checkinEndDate
		} else {
			updatedCheckinEndDate = self.checkinEndDate
		}

		let updatedCheckinCompleted: Bool
		if let checkinCompleted = checkinCompleted {
			updatedCheckinCompleted = checkinCompleted
		} else {
			updatedCheckinCompleted = self.checkinCompleted
		}

		let updatedCheckinSubmitted: Bool
		if let checkinSubmitted = checkinSubmitted {
			updatedCheckinSubmitted = checkinSubmitted
		} else {
			updatedCheckinSubmitted = self.checkinSubmitted
		}
		
		let updateCreateJournalEntry: Bool
		if let createJournalEntry = createJournalEntry {
			updateCreateJournalEntry = createJournalEntry
		} else {
			updateCreateJournalEntry = self.createJournalEntry
		}
		
		return Checkin(
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
			checkinStartDate: updatedCheckinStartDate,
			checkinEndDate: updatedCheckinEndDate,
			checkinCompleted: updatedCheckinCompleted,
			createJournalEntry: updateCreateJournalEntry,
			checkinSubmitted: updatedCheckinSubmitted
		)
	}
}

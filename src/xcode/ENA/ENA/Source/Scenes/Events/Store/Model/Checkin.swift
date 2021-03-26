////
// 🦠 Corona-Warn-App
//

import Foundation

struct Checkin: Equatable {

	let id: Int
	let traceLocationGUID: String
	let traceLocationGUIDHash: Data
	let traceLocationVersion: Int
	let traceLocationType: TraceLocationType
	let traceLocationDescription: String
	let traceLocationAddress: String
	let traceLocationStartDate: Date?
	let traceLocationEndDate: Date?
	let traceLocationDefaultCheckInLengthInMinutes: Int?
	let traceLocationSignature: String
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
}

extension Checkin {
	func prepareForSubmission() throws -> SAP_Internal_Pt_CheckIn {
		var checkin = SAP_Internal_Pt_CheckIn()
		checkin.startIntervalNumber = self.checkinEndDate
		checkin.endIntervalNumber = 0

		try checkin.signedLocation = {
			var signed = SAP_Internal_Pt_SignedTraceLocation()
			signed.location = try {
				var loc = SAP_Internal_Pt_TraceLocation()
				// ...
				return try loc.serializedData()
			}()
			signed.signature = Data() // TODO
			// ...
			return signed
		}()
		return checkin
	}
}

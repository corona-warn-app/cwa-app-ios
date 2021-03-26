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

	/// Extract and return the  trace location of the current checkin
	var traceLocation: SAP_Internal_Pt_TraceLocation {
		var loc = SAP_Internal_Pt_TraceLocation()
		loc.guid = traceLocationGUID
		loc.version = UInt32(traceLocationVersion)
		loc.description_p = traceLocationDescription
		loc.address = traceLocationAddress
		loc.startTimestamp = UInt64(traceLocationStartDate?.timeIntervalSince1970 ?? 0)
		loc.endTimestamp = UInt64(traceLocationEndDate?.timeIntervalSince1970 ?? 0)
		loc.defaultCheckInLengthInMinutes = UInt32(traceLocationDefaultCheckInLengthInMinutes ?? 0)
		return loc
	}

	/// Converts a `Checkin` to the protobuf structure required for submission
	/// - Throws: `BinaryEncodingError` in case the conversion to a serialized signed location fails
	/// - Returns: The converted `SAP_Internal_Pt_CheckIn`
	func prepareForSubmission() throws -> SAP_Internal_Pt_CheckIn {
		var checkin = SAP_Internal_Pt_CheckIn()

		// 10 minute time interval; derived from the unix timestamps
		// see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#derive-10-minute-interval-from-timestamp
		checkin.startIntervalNumber = UInt32(checkinEndDate.timeIntervalSince1970 / 600)
		checkin.endIntervalNumber = UInt32(checkinEndDate.timeIntervalSince1970 / 600)
		assert(checkin.startIntervalNumber < checkin.endIntervalNumber)

		try checkin.signedLocation = {
			var signed = SAP_Internal_Pt_SignedTraceLocation()
			signed.location = try traceLocation.serializedData()
			signed.signature = Data(base64Encoded: traceLocationSignature) ?? Data()
			return signed
		}()

		checkin.transmissionRiskLevel = 42 // TODO: dummy value
		return checkin
	}
}

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

	var overlapInSeconds: Int = 0
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

// MARK: - Submission handling

extension Checkin {

	/// a 10 minute interval
	private static let INTERVAL_LENGTH: TimeInterval = 600

	/// Extract and return the  trace location of the current checkin
	var traceLocation: SAP_Internal_Pt_TraceLocation {
		var loc = SAP_Internal_Pt_TraceLocation()
		loc.version = UInt32(traceLocationVersion)
		loc.description_p = traceLocationDescription
		loc.address = traceLocationAddress
		loc.startTimestamp = UInt64(traceLocationStartDate?.timeIntervalSince1970 ?? 0)
		loc.endTimestamp = UInt64(traceLocationEndDate?.timeIntervalSince1970 ?? 0)
		return loc
	}

	func derivingWarningTimeInterval(config: PresenceTracingSubmissionConfiguration) -> Checkin? {
		let startTimestamp = Int(checkinStartDate.timeIntervalSince1970)
		let endTimestamp = Int(checkinEndDate.timeIntervalSince1970)

		let durationInSeconds =	max(0, endTimestamp - startTimestamp)
		let durationInMinutes = durationInSeconds / 60

		let dropDueToDuration = config.durationFilters
			.map { $0.dropIfMinutesInRange.contains(durationInMinutes) }
			.contains(true)

		if dropDueToDuration {
			return nil
		}

		let aerosoleDecayInSeconds = config.aerosoleDecayLinearFunctions
			.first { $0.minutesRange.contains(durationInMinutes) }
			.map {
				$0.slope * Double(durationInSeconds) + $0.intercept * 60
			} ?? 0

		let targetDurationInSeconds = round((Double(durationInSeconds) + aerosoleDecayInSeconds) / 600) * 600

		let relevantStartTimestamp = startTimestamp
		let relevantEndTimestamp = endTimestamp + Int(aerosoleDecayInSeconds)

		let relevantStartIntervalTimestamp = Int(relevantStartTimestamp / 600) * 600
		let relevantEndIntervalTimestamp = Int(relevantEndTimestamp / 600) * 600

		let overlapWithStartInterval = relevantStartIntervalTimestamp + 600 - relevantStartTimestamp
		let overlapWithEndInterval = relevantEndTimestamp - relevantEndIntervalTimestamp

		let newStartTimestamp: TimeInterval
		let newEndTimestamp: TimeInterval
		if overlapWithEndInterval > overlapWithStartInterval {
			newEndTimestamp = TimeInterval(relevantEndIntervalTimestamp + 600)
			newStartTimestamp = newEndTimestamp - targetDurationInSeconds
		} else {
			newStartTimestamp = TimeInterval(relevantStartIntervalTimestamp)
			newEndTimestamp = newStartTimestamp + targetDurationInSeconds
		}

		return Checkin(
			id: id,
			traceLocationId: traceLocationId,
			traceLocationIdHash: traceLocationIdHash,
			traceLocationVersion: traceLocationVersion,
			traceLocationType: traceLocationType,
			traceLocationDescription: traceLocationDescription,
			traceLocationAddress: traceLocationAddress,
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey,
			checkinStartDate: Date(timeIntervalSince1970: newStartTimestamp),
			checkinEndDate: Date(timeIntervalSince1970: newEndTimestamp),
			checkinCompleted: checkinCompleted,
			createJournalEntry: createJournalEntry
		)
	}

	/// Converts a `Checkin` to the protobuf structure required for submission
	/// - Throws: `BinaryEncodingError` in case the conversion to a serialized signed location fails
	/// - Returns: The converted `SAP_Internal_Pt_CheckIn`
	func prepareForSubmission() -> SAP_Internal_Pt_CheckIn {
		var checkin = SAP_Internal_Pt_CheckIn()

		// 10 minute time interval; derived from the unix timestamps
		// see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#derive-10-minute-interval-from-timestamp
		checkin.startIntervalNumber = UInt32(checkinStartDate.timeIntervalSince1970 / Checkin.INTERVAL_LENGTH)
		checkin.endIntervalNumber = UInt32(checkinEndDate.timeIntervalSince1970 / Checkin.INTERVAL_LENGTH)
		assert(checkin.startIntervalNumber <= checkin.endIntervalNumber)
		checkin.locationID = traceLocationId

		// `transmissionRiskLevel` currently calculated outside this function and left at the default value
		return checkin
	}
}

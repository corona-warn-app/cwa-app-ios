////
// 🦠 Corona-Warn-App
//

import Foundation

protocol TraceWarningMatching {
	
	func matchAndStore(package: SAPDownloadedPackage)
	
}

final class TraceWarningMatcher: TraceWarningMatching {

	// MARK: - Init
	
	init(
		eventStore: EventStoringProviding
	) {
		self.eventStore = eventStore
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningMatching
	
	func matchAndStore(package: SAPDownloadedPackage) {
		/*
		
		Filter for Matches: for each downloaded TraceWarningPackage that is not empty (i.e. not a zip file, cwa-empty-pkg header set), the corresponding items of Protocol Buffer message TraceTimeIntervalWarning are filtered for those that have an overlap time of > 0 with any of check-ins from the Database Table for CheckIns as per Calculate Overlap of CheckIn and TraceTimeIntervalWarning. A match references a check-in, a TraceWarningPackage, and a TraceTimeIntervalWarning.

		Store Matches: all matches are stored as a corresponding record in the Database Table for TraceTimeIntervalMatches as follows:

		Check In ID column set to the ID of the check-in (from Database Table for CheckIns) that caused the match

		TraceWarningPackage ID column set to the identifier of the TraceWarningPackage that produced the match

		TraceLocation GUID column set to the corresponding column of the check-in (from Database Table for CheckIns)

		Transmission Risk Level column set to the transmissionRiskLevel attribute from the TraceTimeIntervalWarning

		StartIntervalNumber column set to the startIntervalNumber attribute from TraceTimeIntervalWarning

		EndIntervalNumber column set to the sum of value of the startIntervalNumber attribute plus the value of the period attribute from TraceTimeIntervalWarning
		
		*/

		guard let warningPackage = try? SAP_Internal_Pt_TraceWarningPackage(serializedData: package.bin) else {
			return
		}
		matchAndStore(package: warningPackage)
	}

	// MARK: - Internal

	func matchAndStore(package: SAP_Internal_Pt_TraceWarningPackage) {

		for warning in package.timeIntervalWarnings {
			var checkins: [Checkin] = eventStore.checkinsPublisher.value.filter {
				$0.traceLocationGUIDHash == warning.locationGuidHash
			}

			checkins = checkins.filter {
				// TODO: Filter based on time overlap
				print($0)
				return true
			}

			for checkin in checkins {
				let match = TraceTimeIntervalMatch(
					id: 0,
					checkinId: checkin.id,
					traceWarningPackageId: Int(package.intervalNumber),
					traceLocationGUID: checkin.traceLocationGUID,
					transmissionRiskLevel: Int(warning.transmissionRiskLevel),
					startIntervalNumber: Int(warning.startIntervalNumber),
					endIntervalNumber: Int(warning.startIntervalNumber + warning.period)
				)
				eventStore.createTraceTimeIntervalMatch(match)
			}
		}
	}

//	// Util
//	const toTimestamp = intervalNumber => intervalNumber * 600
//
//	const calculateOverlap = ({ checkIn, traceTimeIntervalWarning }) => {
//	  if (checkIn.traceLocationGuidHash !== traceTimeIntervalWarning.locationGuidHash) return 0
//
//	  const endIntervalNumber = traceTimeIntervalWarning.startIntervalNumber + traceTimeIntervalWarning.period
//	  const warningStartTimestamp = toTimestamp(traceTimeIntervalWarning.startIntervalNumber)
//	  const warningEndTimestamp = toTimestamp(endIntervalNumber)
//
//	  const overlapStartTimestamp = Math.max(checkIn.startTimestamp, warningStartTimestamp)
//	  const overlapEndTimestamp = Math.min(checkIn.endTimestamp, warningEndTimestamp)
//	  const overlapInSeconds = overlapEndTimestamp - overlapStartTimestamp
//
//	  if (overlapInSeconds < 0) return 0
//	  else return Math.round(overlapInSeconds / 60)
//	}

	// MARK: - Private

	// Algorithm from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/sample-code/presence-tracing/pt-calculate-overlap.js

	private func calculateOverlap(checkin: Checkin, warning: SAP_Internal_Pt_TraceTimeIntervalWarning) -> Int {

		func toTimeInterval(_ intervalNumber: UInt32) -> TimeInterval {
			TimeInterval(intervalNumber * 600)
		}

		let endIntervalNumber = warning.startIntervalNumber + warning.period

		let warningStartTimestamp = toTimeInterval(warning.startIntervalNumber)
		let warningEndTimestamp = toTimeInterval(endIntervalNumber)

		let overlapStartTimestamp = max(checkin.checkinStartDate.timeIntervalSince1970, warningStartTimestamp)
		let overlapEndTimestamp = min(checkin.checkinEndDate.timeIntervalSince1970, warningEndTimestamp)
		let overlapInSeconds = overlapEndTimestamp - overlapStartTimestamp

		if overlapInSeconds < 0 {
			return 0
		} else {
			return Int(round(overlapInSeconds / 60))
		}
	}
	
	private let eventStore: EventStoringProviding
}

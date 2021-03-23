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

	func matchAndStore(package: SAP_Internal_Pt_TraceWarningPackage) {

		for warning in package.timeIntervalWarnings {
			var checkins: [Checkin] = eventStore.checkinsPublisher.value.filter {
				// TODO: Compare hash
				print($0)
				return true
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
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let eventStore: EventStoringProviding
}

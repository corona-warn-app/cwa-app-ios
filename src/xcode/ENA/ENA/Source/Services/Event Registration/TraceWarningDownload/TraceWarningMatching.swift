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
				calculateOverlap(checkin: $0, warning: warning) > 0
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

	// Algorithm from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/sample-code/presence-tracing/pt-calculate-overlap.js

	func calculateOverlap(checkin: Checkin, warning: SAP_Internal_Pt_TraceTimeIntervalWarning) -> Int {

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

	// MARK: - Private
	
	private let eventStore: EventStoringProviding
}

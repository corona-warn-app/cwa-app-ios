////
// 🦠 Corona-Warn-App
//

import Foundation

protocol TraceWarningMatching {

	func matchAndStore(package: SAPDownloadedPackage, encrypted: Bool)
	func calculateOverlap(checkin: Checkin, warning: SAP_Internal_Pt_TraceTimeIntervalWarning) -> Int
	func calculateOverlap(checkin: Checkin, match: TraceTimeIntervalMatch) -> Int

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

	func matchAndStore(package: SAPDownloadedPackage, encrypted: Bool) {
		Log.info("[TraceWarningMatching] Start matching TraceTimeIntervalWarnings against Checkins. encrypted: \(encrypted) ", log: .checkin)

		guard let warningPackage = try? SAP_Internal_Pt_TraceWarningPackage(serializedData: package.bin) else {
			Log.error("[TraceWarningMatching] Failed to decode SAPDownloadedPackage", log: .checkin)
			return
		}

		Log.info("[TraceWarningMatching] Package interval number: \(warningPackage.intervalNumber)", log: .checkin)

		if encrypted {
			matchAndStore(checkInProtectedReports: warningPackage.checkInProtectedReports, intervalNumber: Int(warningPackage.intervalNumber))
		} else {
			matchAndStore(warnings: warningPackage.timeIntervalWarnings, intervalNumber: Int(warningPackage.intervalNumber))
		}
	}

	func calculateOverlap(checkin: Checkin, warning: SAP_Internal_Pt_TraceTimeIntervalWarning) -> Int {
		let endIntervalNumber = warning.startIntervalNumber + warning.period

		return calculateOverlap(
			checkin: checkin,
			startIntervalNumber: Int(warning.startIntervalNumber),
			endIntervalNumber: Int(endIntervalNumber)
		)
	}

	func calculateOverlap(checkin: Checkin, match: TraceTimeIntervalMatch) -> Int {
		calculateOverlap(
			checkin: checkin,
			startIntervalNumber: match.startIntervalNumber,
			endIntervalNumber: match.endIntervalNumber
		)
	}

	// MARK: - Internal

	func matchAndStore(checkInProtectedReports: [SAP_Internal_Pt_CheckInProtectedReport], intervalNumber: Int) {
		// Check for early return
		guard !checkInProtectedReports.isEmpty else {
			return
		}

		// Filter for matches

		struct ReportWithLocationId {
			let report: SAP_Internal_Pt_CheckInProtectedReport
			let locationId: Data
		}

		let reportsWithLocationId = checkInProtectedReports.compactMap { report -> ReportWithLocationId? in
			let matchingCheckin = eventStore.checkinsPublisher.value.first { checkin -> Bool in
				return true //report.locationIDHash == checkin.traceLocationIdHash
			}
			if let matchingCheckin = matchingCheckin {
				return ReportWithLocationId(report: report, locationId: matchingCheckin.traceLocationId)
			} else {
				return nil
			}
		}

		let checkinEncryption = CheckinEncryption()
		var warnings = [SAP_Internal_Pt_TraceTimeIntervalWarning]()

		// Decrypt checkins.

		for reportWithLocationId in reportsWithLocationId {
			let decryptionResult = checkinEncryption.decrypt(
				locationId: reportWithLocationId.locationId,
				encryptedCheckinRecord: reportWithLocationId.report.encryptedCheckInRecord,
				initializationVector: reportWithLocationId.report.iv,
				messageAuthenticationCode: reportWithLocationId.report.mac
			)

			switch decryptionResult {
			case .success(let checkinRecord):

				// Drop suspicious data
				guard checkinRecord.startIntervalNumber >= 0,
					  checkinRecord.period > 0,
					  checkinRecord.transmissionRiskLevel >= 1 && checkinRecord.transmissionRiskLevel <= 8 else {
					continue
				}

				// Map to TraceTimeIntervalWarnings
				var warning = SAP_Internal_Pt_TraceTimeIntervalWarning()
				warning.locationIDHash = reportWithLocationId.report.locationIDHash
				warning.startIntervalNumber = checkinRecord.startIntervalNumber
				warning.period = checkinRecord.period
				warning.transmissionRiskLevel = checkinRecord.transmissionRiskLevel

				warnings.append(warning)

			case .failure(let error):
				Log.error("[TraceWarningMatching] Failed decrypting CheckInProtectedReport", log: .checkin, error: error)
			}
		}

		matchAndStore(warnings: warnings, intervalNumber: intervalNumber)
	}

	func matchAndStore(warnings: [SAP_Internal_Pt_TraceTimeIntervalWarning], intervalNumber: Int) {

		for warning in warnings {
			Log.info("[TraceWarningMatching] Warning startIntervalNumber: \(warning.startIntervalNumber), period: \(warning.period)", log: .checkin)
			Log.debug("[TraceWarningMatching] Warning : \(warning)", log: .checkin)

			// Filter checkins with same id hash.
			var checkins: [Checkin] = eventStore.checkinsPublisher.value.filter {
				$0.traceLocationIdHash == warning.locationIDHash
			}

			guard !checkins.isEmpty else {
				continue
			}
			Log.info("[TraceWarningMatching] Found \(checkins.count) matches with the same location id hash.", log: .checkin)

			// Filter checkins where the warning overlaps the timeframe.
			checkins = checkins.filter {
				calculateOverlap(checkin: $0, warning: warning) > 0
			}

			guard !checkins.isEmpty else {
				continue
			}
			Log.info("[TraceWarningMatching] Found \(checkins.count) overlaping matches.", log: .checkin)

			// Persist checkins and warning as matches.
			for checkin in checkins {
				let match = TraceTimeIntervalMatch(
					id: 0, // createTraceTimeIntervalMatch will ignore this id. The id is generated by the database.
					checkinId: checkin.id,
					traceWarningPackageId: intervalNumber,
					traceLocationId: checkin.traceLocationId,
					transmissionRiskLevel: Int(warning.transmissionRiskLevel),
					startIntervalNumber: Int(warning.startIntervalNumber),
					endIntervalNumber: Int(warning.startIntervalNumber + warning.period)
				)

				Log.info("[TraceWarningMatching] Persist match with checkin.id: \(checkin.id) and package.intervalNumber: \(intervalNumber). ", log: .checkin)
				eventStore.createTraceTimeIntervalMatch(match)
			}
		}
	}

	// MARK: - Private
	
	private let eventStore: EventStoringProviding

	// Algorithm from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/sample-code/presence-tracing/pt-calculate-overlap.js

	private func calculateOverlap(checkin: Checkin, startIntervalNumber: Int, endIntervalNumber: Int) -> Int {
		func toTimeInterval(_ intervalNumber: Int) -> TimeInterval {
			TimeInterval(intervalNumber * 600)
		}

		let warningStartTimestamp = toTimeInterval(startIntervalNumber)
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

}

//
// 🦠 Corona-Warn-App
//

import Foundation

/// Used to configure a `RiskLevelProvider`.
struct RiskProvidingConfiguration {

    static let defaultExposureDetectionsInterval = 24 / defaultMaxExposureDetectionsPerInterval
    private static let defaultMaxExposureDetectionsPerInterval = 1

	static var `default`: RiskProvidingConfiguration {
		return RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 2),
			exposureDetectionInterval: DateComponents(hour: defaultExposureDetectionsInterval),
			detectionMode: .default
		)
	}

	/// The duration a conducted exposure detection is considered valid.
	var exposureDetectionValidityDuration: DateComponents

	/// Time interval between exposure detections.
	var exposureDetectionInterval: DateComponents

	/// The mode of operation
	var detectionMode: DetectionMode = DetectionMode.default
}

/// Either a concrete date or now
enum NextExposureDetection: Equatable {
	case date(Date)
	case now

	static func == (lhs: NextExposureDetection, rhs: NextExposureDetection) -> Bool {
		switch (lhs, rhs) {
		case (.now, .now):
			return true
		case let (.date(a), .date(b)):
			// return true if dates are less than 30 seconds apart
			return abs(a.timeIntervalSince(b)) < 30.0
		default:
			return false
		}
	}
}

extension RiskProvidingConfiguration {
	func exposureDetectionValidUntil(lastExposureDetectionDate: Date?) -> Date {
		Calendar.current.date(
			byAdding: exposureDetectionValidityDuration,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
			) ?? .distantPast
	}

	func nextExposureDetectionDate(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> NextExposureDetection {
		let potentialDate = Calendar.current.date(
			byAdding: exposureDetectionInterval,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
		) ?? .distantPast
		Log.debug("[RiskProvidingConfiguration] Exposure detection interval:\(exposureDetectionInterval)", log: .riskDetection)
		Log.debug("[RiskProvidingConfiguration] Next potential detection date:\(potentialDate)", log: .riskDetection)
		return potentialDate > currentDate ? .date(potentialDate) : .now
	}

	func exposureDetectionIsValid(lastExposureDetectionDate: Date = .distantPast, currentDate: Date = Date()) -> Bool {
		// It is not valid to have a future exposure detection date
		guard lastExposureDetectionDate <= currentDate else { return false }

		return currentDate < exposureDetectionValidUntil(lastExposureDetectionDate: lastExposureDetectionDate)
	}

	/// Checks, whether a new exposureDetection may be triggered
	///
	/// - Parameters:
	///     - activeTracingHours: The amount of hours where the contact tracing protocol has been active within the relevant timeframe.
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	///     - currentDate: Current timestamp.
	func shouldPerformExposureDetection(activeTracingHours: Int, lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Bool {
		// Don't allow exposure detection within the first frame of exposureDetectionInterval
		guard activeTracingHours >= TracingStatusHistory.minimumActiveHours else {
			Log.info("[RiskProvidingConfiguration] Not enough tracing hours.", log: .riskDetection)
			return false
		}

		if let lastExposureDetectionDate = lastExposureDetectionDate, lastExposureDetectionDate > currentDate {
			// It is not valid to have a future exposure detection date.
			Log.info("[RiskProvidingConfiguration] Last exposure date is in the future. Are you Marty McFly?", log: .riskDetection)
			return true
		}
		let next = nextExposureDetectionDate(lastExposureDetectionDate: lastExposureDetectionDate, currentDate: currentDate)

		switch next {
		case .now:
			return true
		case .date(let date):
			Log.debug("[RiskProvidingConfiguration] Last exposure date :\(date)", log: .riskDetection)
			Log.debug("[RiskProvidingConfiguration] Current date :\(currentDate)", log: .riskDetection)
			return date <= currentDate
		}
	}

	/// Checks, whether a new exposureDetection may be triggered manually by the user.
	///
	/// - Parameters:
	///     - activeTracingHours: The amount of hours where the contact tracing protocol has been active within the relevant timeframe.
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	func manualExposureDetectionState(activeTracingHours: Int, lastExposureDetectionDate detectionDate: Date?) -> ManualExposureDetectionState? {
		guard detectionMode != .automatic else {
			return nil
		}
		return shouldPerformExposureDetection(activeTracingHours: activeTracingHours, lastExposureDetectionDate: detectionDate) ? .possible : .waiting
	}
}

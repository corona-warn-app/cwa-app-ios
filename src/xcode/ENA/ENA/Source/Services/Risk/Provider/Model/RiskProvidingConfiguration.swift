//
// 🦠 Corona-Warn-App
//

import Foundation

/// Used to configure a `RiskLevelProvider`.
struct RiskProvidingConfiguration: Equatable {

    static let defaultExposureDetectionsInterval = 24 / defaultMaxExposureDetectionsPerInterval
    private static let defaultMaxExposureDetectionsPerInterval = 1

	static var `default`: RiskProvidingConfiguration {
		return RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 2),
			exposureDetectionInterval: DateComponents(hour: defaultExposureDetectionsInterval),
			detectionMode: DetectionMode.fromBackgroundStatus()
		)
	}

	/// The duration a conducted exposure detection is considered valid.
	var exposureDetectionValidityDuration: DateComponents

	/// Time interval between exposure detections.
	var exposureDetectionInterval: DateComponents

	/// The mode of operation
	var detectionMode: DetectionMode = DetectionMode.default
}

extension RiskProvidingConfiguration {
	
	func nextExposureDetectionDate(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Date {
		let potentialDate = Calendar.current.date(
			byAdding: exposureDetectionInterval,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
		) ?? .distantPast
        Log.debug("[RiskProvidingConfiguration] Next potential detection date: \(potentialDate)", log: .riskDetection)
        Log.debug("[RiskProvidingConfiguration] Exposure detection interval: \(exposureDetectionInterval)", log: .riskDetection)
		return max(potentialDate, currentDate)
	}

	/// Checks, whether a new exposureDetection may be triggered
	///
	/// - Parameters:
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	///     - currentDate: Current timestamp.
	func shouldPerformExposureDetection(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Bool {
        Log.debug("[RiskProvidingConfiguration] Last exposure date input: \(String(describing: lastExposureDetectionDate))", log: .riskDetection)
		if let lastExposureDetectionDate = lastExposureDetectionDate, lastExposureDetectionDate > currentDate {
			// It is not valid to have a future exposure detection date.
			return true
		}
		let nextDate = nextExposureDetectionDate(lastExposureDetectionDate: lastExposureDetectionDate, currentDate: currentDate)

		return nextDate <= currentDate
	}

	/// Checks, whether a new exposureDetection may be triggered manually by the user.
	///
	/// - Parameters:
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	func manualExposureDetectionState(lastExposureDetectionDate detectionDate: Date?) -> ManualExposureDetectionState? {
		guard detectionMode != .automatic else {
			return nil
		}
		return shouldPerformExposureDetection(lastExposureDetectionDate: detectionDate) ? .possible : .waiting
	}
}

//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit

extension ExposureDetectionViewController {

	struct State {

		var riskState: RiskState

		var detectionMode: DetectionMode = DetectionMode.default

		var isTracingEnabled: Bool {
			if case .inactive = riskState {
				return false
			} else {
				return true
			}
		}
		
		var activityState: RiskProviderActivityState = .idle

		var riskLevel: RiskLevel {
			if case .risk(let risk) = riskState {
				return risk.level
			}

			return .low
		}

		var riskDetectionFailed: Bool {
			riskState == .detectionFailed
		}

		var riskDetails: Risk.Details? {
			if case .risk(let risk) = riskState {
				return risk.details
			}

			return nil
		}

		let previousRiskLevel: RiskLevel?

		var actualRiskText: String {
			switch previousRiskLevel {
			case .low:
				return AppStrings.ExposureDetection.low
			case .high:
				return AppStrings.ExposureDetection.high
			default:
				return AppStrings.ExposureDetection.unknown
			}
		}

		var titleText: String {
			switch activityState {
			case .detecting:
				return AppStrings.ExposureDetection.riskCardStatusDetectingTitle
			case .downloading:
				return AppStrings.ExposureDetection.riskCardStatusDownloadingTitle
			case .idle, .riskRequested:
				if !isTracingEnabled {
					return AppStrings.ExposureDetection.off
				}

				if riskDetectionFailed {
					return AppStrings.ExposureDetection.riskCardFailedCalculationTitle
				}

				return riskLevel.text
			}
		}

		var riskBackgroundColor: UIColor {
			!isTracingEnabled || riskDetectionFailed ? .enaColor(for: .background) : riskLevel.backgroundColor
		}

		var riskTintColor: UIColor {
			!isTracingEnabled || riskDetectionFailed ? .enaColor(for: .riskNeutral) : riskLevel.tintColor
		}

		var riskContrastTintColor: UIColor {
			!isTracingEnabled || riskDetectionFailed ? .enaColor(for: .riskNeutral) : riskLevel.contrastTintColor
		}

		var titleTextColor: UIColor {
			!isTracingEnabled || riskDetectionFailed ? .enaColor(for: .textPrimary1) : riskLevel.contrastTextColor
		}

	}

}

private extension RiskLevel {

	var text: String {
		switch self {
		case .low: return AppStrings.ExposureDetection.low
		case .high: return AppStrings.ExposureDetection.high
		}
	}

	var backgroundColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .riskLow)
		case .high: return .enaColor(for: .riskHigh)
		}
	}

	var tintColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .riskLow)
		case .high: return .enaColor(for: .riskHigh)
		}
	}

	var contrastTintColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .textContrast)
		case .high: return .enaColor(for: .textContrast)
		}
	}

	var contrastTextColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .textContrast)
		case .high: return .enaColor(for: .textContrast)
		}
	}

}

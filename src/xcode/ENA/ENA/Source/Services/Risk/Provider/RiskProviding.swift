//
// 🦠 Corona-Warn-App
//

import Foundation

typealias RiskCalculationResult = Result<Risk, RiskProviderError>

enum RiskProviderError: Error {
	case timeout
	case riskProviderIsRunning
	case missingAppConfig
	case failedKeyPackageDownload(KeyPackageDownloadError)
	case missingCachedSummary
	case failedToDetectSummary
	case failedRiskCalculation
	case failedRiskDetection(ExposureDetection.DidEndPrematurelyReason)

	var isAlreadyRunningError: Bool {
		switch self {
		case .riskProviderIsRunning:
			return true
		case .failedKeyPackageDownload(let keyPackageDownloadError):
			return keyPackageDownloadError == .downloadIsRunning
		case .failedRiskDetection(let didEndPrematuralyReason):
			if case let .noSummary(summaryError) = didEndPrematuralyReason {
				if let exposureDetectionError = summaryError as? ExposureDetectionError {
					return exposureDetectionError == .isAlreadyRunning
				}
			}
		default:
			break
		}

		return false
	}
}

protocol RiskProviding: AnyObject {
	typealias Completion = (RiskCalculationResult) -> Void

	func observeRisk(_ consumer: RiskConsumer)
	func requestRisk(userInitiated: Bool, ignoreCachedSummary: Bool, completion: Completion?)
	func nextExposureDetectionDate() -> Date

	var riskProvidingConfiguration: RiskProvidingConfiguration { get set }
}

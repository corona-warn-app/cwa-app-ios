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
}

protocol RiskProviding: AnyObject {
	typealias Completion = (RiskCalculationResult) -> Void

	func observeRisk(_ consumer: RiskConsumer)
	func requestRisk(userInitiated: Bool, ignoreCachedSummary: Bool, completion: Completion?)
	func nextExposureDetectionDate() -> Date

	var riskProvidingConfiguration: RiskProvidingConfiguration { get set }
}

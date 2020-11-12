//
// 🦠 Corona-Warn-App
//

import Foundation

typealias RiskCalculationResult = Result<Risk, RiskCalculationError>

enum RiskCalculationError: Error {
	case timeout
	case missingAppConfig
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

	var configuration: RiskProvidingConfiguration { get set }
}

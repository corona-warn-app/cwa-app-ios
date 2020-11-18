//
// 🦠 Corona-Warn-App
//

import Foundation

typealias RiskProviderResult = Result<Risk, RiskProviderError>

enum RiskProviderError: Error {
	case inactive
	case timeout
	case riskProviderIsRunning
	case missingAppConfig
	case failedKeyPackageDownload(KeyPackageDownloadError)
	case failedRiskCalculation
	case failedRiskDetection(ExposureDetection.DidEndPrematurelyReason)
}

enum RiskProviderActivityState {
	case idle
	case riskRequested
	case downloading
	case detecting

	var isActive: Bool {
		self == .downloading || self == .detecting
	}
}

protocol RiskProviding: AnyObject {
	typealias Completion = (RiskProviderResult) -> Void

	var riskProvidingConfiguration: RiskProvidingConfiguration { get set }
	var exposureManagerState: ExposureManagerState { get set }
	var activityState: RiskProviderActivityState { get }
	var manualExposureDetectionState: ManualExposureDetectionState? { get }
	var nextExposureDetectionDate: Date { get }

	func observeRisk(_ consumer: RiskConsumer)
	func removeRisk(_ consumer: RiskConsumer)

	func requestRisk(userInitiated: Bool)
	func requestRisk(userInitiated: Bool, completion: Completion?)

}

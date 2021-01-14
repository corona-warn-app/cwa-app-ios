//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification
@testable import ENA

class MockRiskProvider: RiskProviding {
	
	// MARK: - Init
	
	init(
		riskProvidingConfiguration: RiskProvidingConfiguration = .default,
		exposureManagerState: ExposureManagerState = .init(authorized: true, enabled: true, status: .active),
		activityState: RiskProviderActivityState = .idle,
		manualExposureDetectionState: ManualExposureDetectionState? = nil,
		nextExposureDetectionDate: Date = Date(),
		result: RiskProviderResult = .success(.mocked)
	) {
		self.riskProvidingConfiguration = riskProvidingConfiguration
		self.exposureManagerState = exposureManagerState
		self.activityState = activityState
		self.manualExposureDetectionState = manualExposureDetectionState
		self.nextExposureDetectionDate = nextExposureDetectionDate
		self.result = result
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol RiskProviding
	
	var riskProvidingConfiguration: RiskProvidingConfiguration
	var exposureManagerState: ExposureManagerState
	var activityState: RiskProviderActivityState
	var manualExposureDetectionState: ManualExposureDetectionState?
	var nextExposureDetectionDate: Date

	func observeRisk(_ consumer: RiskConsumer) {
		consumers.insert(consumer)
	}

	func removeRisk(_ consumer: RiskConsumer) {
		consumers.remove(consumer)
	}

	func requestRisk(userInitiated: Bool, timeoutInterval: TimeInterval) {
		for consumer in consumers {
			consumer.didChangeActivityState?(.riskRequested)
			consumer.didChangeActivityState?(.downloading)
			consumer.didChangeActivityState?(.detecting)
			consumer.didChangeActivityState?(.idle)
			consumer.provideRiskCalculationResult(result)
		}
	}

	
	// MARK: - Internal
	
	var result: RiskProviderResult
	
	// MARK: - Private
	
	private var consumers: Set<RiskConsumer> = Set<RiskConsumer>()
	
}


private extension RiskConsumer {
	func provideRiskCalculationResult(_ result: RiskProviderResult) {
		switch result {
		case .success(let risk):
			targetQueue.async { [weak self] in
				self?.didCalculateRisk(risk)
			}
		case .failure(let error):
			targetQueue.async { [weak self] in
				self?.didFailCalculateRisk(error)
			}
		}
	}
}

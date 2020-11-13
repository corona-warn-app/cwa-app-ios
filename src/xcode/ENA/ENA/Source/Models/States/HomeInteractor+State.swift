//
// 🦠 Corona-Warn-App
//

import Foundation
extension HomeInteractor {
	struct State: Equatable {
		var riskDetectionFailed: Bool
		var detectionMode: DetectionMode
		var exposureManagerState: ExposureManagerState
		var enState: ENStateHandler.State

		var risk: Risk?
		var riskLevel: RiskLevel? { risk?.level }
		var numberRiskContacts: Int {
			risk?.details.numberOfExposures ?? 0
		}

		var daysSinceLastExposure: Int? {
			risk?.details.daysSinceLastExposure
		}

		init(
			detectionMode: DetectionMode,
			exposureManagerState: ExposureManagerState,
			enState: ENStateHandler.State,
			risk: Risk?,
			riskDetectionFailed: Bool
		) {
			self.detectionMode = detectionMode
			self.exposureManagerState = exposureManagerState
			self.enState = enState
			self.risk = risk
			self.riskDetectionFailed = riskDetectionFailed
		}
	}
}

//
// 🦠 Corona-Warn-App
//

import Foundation

extension HomeInteractor {

	struct State: Equatable {

		// MARK: - Internal

		var riskState: RiskState
		var detectionMode: DetectionMode = .fromBackgroundStatus()
		var exposureManagerState: ExposureManagerState
		var enState: ENStateHandler.State

		var riskDetails: Risk.Details? {
			if case .risk(let risk) = riskState {
				return risk.details
			}

			return nil
		}

	}

}

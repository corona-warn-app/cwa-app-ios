//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation

extension HomeInteractor {

	struct State: Equatable {

		// MARK: - Internal

		var riskState: RiskState
		var detectionMode: DetectionMode = .fromBackgroundStatus()
		var exposureManagerState: ExposureManagerState
		var enState: ENStateHandler.State

		var riskLevel: RiskLevel? {
			if case .risk(let risk) = riskState {
				return risk.level
			}

			return nil
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

		var numberRiskContacts: Int {
			if case .risk(let risk) = riskState {
				return risk.details.numberOfExposures
			}

			return 0
		}

		var daysSinceLastExposure: Int? {
			if case .risk(let risk) = riskState {
				return risk.details.daysSinceLastExposure
			}

			return nil
		}

	}

}
